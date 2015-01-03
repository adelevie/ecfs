require "pp"
require "pry"
require "mechanize"

module ECFS

  class SolrScrapeQuery
    attr_accessor :docket_number
    attr_accessor :received_min_date
    attr_accessor :after_scrape
    
    def filings_from_docket_number(docket_number, start=0, received_min_date=nil, after_scrape=nil)
      url = "http://apps.fcc.gov/ecfs/solr/search?sort=dateRcpt&proceeding=#{docket_number}&dir=asc&start=#{start}"
      
      if received_min_date
        url << "&received.minDate=#{received_min_date}"
      end
      
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
        date_received  = columns[2].text.strip
        type_of_filing = columns[3].text.strip
        pages          = columns[4].text.strip.to_i
              
        id = columns[1].search('a').first.attributes['href'].value.split('?id=')[1]
        url = "http://apps.fcc.gov/ecfs/comment/view?id=#{id}"
        
        {
          'docket_number' => proceeding,
          'name_of_filer' => name_of_filer,
          'type_of_filing' => type_of_filing,
          'url' => url,
          'date_received' => date_received,
          'pages' => pages
        }
      end
      
      if after_scrape
        after_scrape.call(filings)
      end
            
      return filings, total
    end
    
    def filing_to_citation(filing)
      patterns = {
        "COMMENT" => "Comments",
        "REPLY TO COMMENTS" => "Reply Comments",
        "NOTICE OF EXPARTE" => "Ex Parte Letter"
      }
  
      case filing["type_of_filing"]
      when "COMMENT"
        return "Comments of #{filing['name_of_filer']}"
      when "REPLY TO COMMENTS"
        return "Reply Comments of #{filing['name_of_filer']}"
      when "NOTICE OF EXPARTE"
        return "#{filing['name_of_filer']} Ex Parte Letter"
      else
        return "#{filing["type_of_filing"].downcase.capitalize} of #{filing['name_of_filer']}"
      end
    end
    
    def get
      url = "http://apps.fcc.gov/ecfs/solr/search?sort=dateRcpt&proceeding=#{@docket_number}&dir=asc&start=0"
      filings = []
      
      first_page_of_filings, total = filings_from_docket_number(@docket_number, 0, @received_min_date, @after_scrape)
      
      pages = (total.to_f/20.0).ceil.to_i.times.map {|n| n*20} # divide, round up, then map *20
      pages.shift
      
      filings.concat first_page_of_filings
      
      pages.each do |page|
        filings.concat filings_from_docket_number(@docket_number, page, @received_min_date, @after_scrape)[0]
      end
      
      filings.each do |filing|
        filing['citation'] = filing_to_citation(filing)
      end

      filings
    end

  end
end
