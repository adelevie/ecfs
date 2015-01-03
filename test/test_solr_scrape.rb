require "helper"
require "pp"
require "pry"

class TestSolrScrape < MiniTest::Unit::TestCase

  def test_synopsis
    VCR.use_cassette('solr_cassette') do
      filings = ECFS::SolrScrapeQuery.new.tap do |q|
        q.docket_number = '12-83'
      end.get
      
      assert filings.first.is_a?(Hash)
      assert filings.first.has_key?('docket_number')
      assert filings.first.has_key?('citation')
    end
  end
  
  def test_received_min_date
    VCR.use_cassette('solr_cassette') do
      filings = ECFS::SolrScrapeQuery.new.tap do |q|
        q.docket_number = '12-83'
        q.received_min_date = '11/28/14'
      end.get
      
      assert filings.first.is_a?(Hash)
      assert filings.first.has_key?('docket_number')
      assert filings.first.has_key?('citation')
      assert filings.first
      
      filing_date = DateTime.strptime(filings.first['date_received'], "%m/%d/%Y")
      min_date = DateTime.strptime('11/28/14', "%m/%d/%Y")
      
      assert filing_date > min_date
    end
  end
  
  class FakeArrayThing
    def initialize
      @filings = []
    end
    
    def concat(filings)
      @filings.concat(filings)
    end
    
    def filings
      @filings
    end
  end
  
  def test_after_scrape
    VCR.use_cassette('solr_cassette') do
      
      @fake_array_thing = FakeArrayThing.new
      
      filings = ECFS::SolrScrapeQuery.new.tap do |q|
        q.docket_number = '12-83'
        q.after_scrape = Proc.new do |filings|
          @fake_array_thing.concat(filings)
        end
      end.get
      
      assert filings.first.is_a?(Hash)
      assert filings.first.has_key?('docket_number')
      assert filings.first.has_key?('citation')
      
      assert_equal filings.length, @fake_array_thing.filings.length
    end
  end

end