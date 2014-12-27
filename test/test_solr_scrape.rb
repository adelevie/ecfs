require "helper"
require "pp"
require "pry"

class TestSolrScrape < MiniTest::Unit::TestCase

  def test_synopsis
    VCR.use_cassette('main_cassette') do
      filings = ECFS::SolrScrapeQuery.new.tap do |q|
        q.docket_number = '12-83'
      end.get
      
      assert filings.first.is_a?(Hash)
      assert filings.first.has_key?('docket_number')
    end
  end

end