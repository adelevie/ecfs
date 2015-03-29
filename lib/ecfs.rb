require 'ecfs/version'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'net/http'
require 'uri'
require 'faraday'
require 'unirest'

module ECFS
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

  module Filings
    ATTRS = [
      :docket, :filer, :lawfirm, :received,
      :posted, :exparte, :type, :pages
    ]

    def self.get_document_links(url)
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
