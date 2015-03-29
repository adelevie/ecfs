require 'ecfs/version'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'net/http'
require 'uri'
require 'unirest'
require 'zip'
require 'open_uri_redirections'
require 'fileutils'

module ECFS
  module Util
    SIGNALS = [
      'E.g.', 'Accord', 'See', 'See also', 'Cf.',
      'Compare', 'Contra', 'But see', 'But cf.',
      'See generally'
    ].map {|s| "#{s} Id."} << 'Id.'

    def self.get_footnotes(url: nil, id_tree: false)
      # hacky 'temp' file
      rando = (rand * 1000000000000000000).to_i
      FileUtils.mkdir_p "tmp/#{rando}"
      path = "tmp/#{rando}/document.doc.zip"

      open(path, 'wb', allow_redirections: :all) do |file|
        file << open(url, allow_redirections: :all).read
        `unzip #{path} -d tmp/#{rando}`
      end

      xml = File.open("tmp/#{rando}/word/footnotes.xml").read
      doc = Nokogiri::XML(xml)

      footnotes = doc.children[0].children[3..-1]

      my_footnotes = footnotes.to_ary.map do |fn|
        {
          index: fn.attributes['id'].value.to_i - 1,
          text: fn.text.strip
        }
      end

      # compute the tree of id. citations
      if id_tree
        my_footnotes.each {|fn| fn[:ids] = []}
        my_footnotes.each {|fn| fn[:id] = false}
        ids = my_footnotes.select {|fn| fn[:text].start_with?(*ECFS::Util::SIGNALS)}
        ids.each {|id| id[:id] = true}

        my_footnotes.each do |fn|
          if fn[:id] == true
            parent_idx = fn[:index]-1
            my_footnotes.find {|fn| fn[:index] == parent_idx}[:ids] << fn
          end
        end

        my_footnotes = send_ids_to_parent(my_footnotes)

      end

      FileUtils.rm_rf("tmp/#{rando}")

      my_footnotes
    end

    private

    # if a footnote is an id and has ids, we send its ids to its parent
    # these footnotes are reflected as parents, but are actually siblings
    # so we call these ptsbs (parents that should be siblings). <3 software.
    def self.send_ids_to_parent(footnotes)
      ptsbs_array = footnotes.select {|fn| fn[:id] == true && fn[:ids].length > 0}
      if ptsbs_array.empty?
        return footnotes
      else
        ptsbs_array.each do |ptsbs|
          parent_idx = ptsbs[:index]-1
          footnotes.find {|fn| fn[:index] == parent_idx}[:ids].concat(ptsbs[:ids])
          ptsbs[:ids] = []
        end
        self.send_ids_to_parent(footnotes)
      end
    end
  end

  module EDOCS
    def self.search(docket: nil, da: nil, fcc: nil, report: nil, file: nil, fcc_rcd_vol: nil, fcc_rcd_page: nil)
      uri = URI.parse("https://apps.fcc.gov/edocs_public/Query.do?mode=advanced&rpt=cond")
      params = {
        'fccNo' => fcc,
        'daNo' => da,
        'fileNo' => file,
        'docket' => docket,
        'reportNo' => report,
        'fccRecordVol' => fcc_rcd_vol,
        'fccRecordPage' => fcc_rcd_page
      }
      params.reject! {|_k,v| v.nil?}

      url = 'https://apps.fcc.gov/edocs_public/Query.do?mode=advance&rpt=cond'
      response = Unirest.post url, parameters: params
      doc = Nokogiri::HTML(response.raw_body)

      tables = doc.css('table.tableWithOutBorder').children.css('table.tableWithOutBorder')
      results = tables[2].css('table.tableWithBorder')

      results.map do |result|
        links = result.search('a').to_a
        links.shift
        links = links.map do |link|
          path = link.attributes["href"].value

          "https://apps.fcc.gov/edocs_public/#{path}"
        end

        word = links.select {|link| link.end_with?('.doc', '.docx')}
        pdf = links.select {|link| link.end_with?('.pdf')}
        txt = links.select {|link| link.end_with?('.txt')}

        rows = result.search('tr')

        {
          title: rows[0].text.strip,
          released: rows[1].text.strip.split(': ')[1],
          description: rows[2].text.strip.split('Description: ')[1],
          word: word,
          pdf: pdf,
          txt: txt
        }.reject {|_k,v| v.nil?}
      end
    end
  end

  module Proceedings
    def self.search(docket: nil)
      url = "http://apps.fcc.gov/ecfs/proceeding/view?name=#{docket}"
      response = Unirest.get url
      doc = Nokogiri::HTML(response.raw_body)
      table = doc.search('table.dataTable').first
      rows = table.search('div.wwgrp')

      proceeding = {}
      rows.each do |row|
        key = row.search('span')[0].text.strip
        key.gsub!(" ", "")
        key.gsub!(":", "")
        key.downcase!
        value = row.search('span')[1].text.strip
        proceeding[key.to_sym] = value
      end

      proceeding
    end
  end

  module Filings
    ATTRS = [
      :docket, :filer, :lawfirm, :received,
      :posted, :exparte, :type, :pages
    ]

    def self.get_document_links(url: url)
      doc = Nokogiri::HTML(open(url))
      xpath = "//*[@id=\"documents.link\"]"
      links = doc.xpath(xpath).search('a')

      links.map do |link|
        id = link.attributes["href"].value.split('?id=')[1]

        "http://apps.fcc.gov/ecfs/document/view?id=#{id}"
      end
    end

    def self.search(docket: nil, size: 1000, start: 0, order: 'asc')
      url = "http://apps.fcc.gov/ecfs/comment_search_solr/doSearch?proceeding=#{docket}&dir=#{order}&start=#{start}&size=#{size}"
      doc = Nokogiri::HTML(open(url))
      xpath = "//*[@id='yui-main']/div/div[4]"
      table = doc.xpath(xpath).children[1]
      rows = table.search('tr')
      rows.shift

      filings = []
      rows.each do |row|
        row_hash = {}
        cols = row.search('td')

        cols.each_with_index do |col, i|
          attribute = ECFS::Filings::ATTRS[i]
          row_hash[attribute] = col.text.strip

          # get the url
          if attribute == :filer
            path = col.search('a').first.attributes["href"].value
            id = path.split('?id=')[1]
            url = "http://apps.fcc.gov/ecfs/comment/view?id=#{id}"
            row_hash[:url] = url
          end
        end

        # cast dates and int
        row_hash[:received] = DateTime.parse(row_hash[:received]).to_s
        row_hash[:posted] = DateTime.parse(row_hash[:posted]).to_s
        row_hash[:pages] = row_hash[:pages].to_i

        filings << row_hash
      end

      filings
    end
  end
end
