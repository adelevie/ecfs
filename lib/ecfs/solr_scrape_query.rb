require "pp"
require "pry"
require "mechanize"

module ECFS

  class SolrScrapeQuery
    attr_accessor :docket_number

    def initialize
    end
    
    def filings_from_docket_number(docket_number, start=0)
      url = "http://apps.fcc.gov/ecfs/solr/search?sort=dateRcpt&proceeding=#{docket_number}&dir=asc&start=#{start}"
      
      agent = Mechanize.new
      page = agent.get(url)
      
      total = page.search('div').find {|div| div.text.start_with?("Showing results")}.text.split('of ')[1].to_i
      table = page.search('div.dataTable table').first
      
      rows = table.search('tr')
      rows.shift
      
      filings = rows.map do |row|
        columns = row.search('td')
      
        proceeding     = columns[0].text.strip
        name_of_filer  = columns[1].text.strip
        date_recieved  = columns[2].text.strip
        type_of_filing = columns[3].text.strip
        pages          = columns[4].text.strip.to_i
              
        id = columns[1].search('a').first.attributes['href'].value.split('?id=')[1]
        url = "http://apps.fcc.gov/ecfs/comment/view?id=#{id}"
        
        {
          'docket_number' => proceeding,
          'name_of_filer' => name_of_filer,
          'type_of_filing' => type_of_filing,
          'url' => url,
          'date_recieved' => date_recieved,
          'pages' => pages
        }
      end
      
      return filings, total
    end
    
    def get(fetch_document_urls=false)
      url = "http://apps.fcc.gov/ecfs/solr/search?sort=dateRcpt&proceeding=#{@docket_number}&dir=asc&start=0"
      filings = []
      
      first_page_of_filings, total = filings_from_docket_number(@docket_number, 0)
      
      pages = (total.to_f/20.0).ceil.to_i.times.map {|n| n*20} # divide, round up, then map *20
      pages.shift
      
      filings.concat first_page_of_filings
      
      pages.each do |page|
        filings.concat filings_from_docket_number(@docket_number, page)[0]
      end
      
      if fetch_document_urls
        p "pretending to fetch some urls"
      end

      filings
    end

  end
end
