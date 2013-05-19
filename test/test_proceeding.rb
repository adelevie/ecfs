require "helper"
require "pp"

class TestProceeding < Test::Unit::TestCase
  

  def test_get_proceeding_info
    VCR.use_cassette('test_proceedings_query_test_get_proceeding_info') do
      #proceedings_query = ECFS::ProceedingsQuery.new
      #proceedings_query.eq("docket_number", "12-375")
      results = ECFS::Proceeding.find("12-375")
      %w[
        bureau_name subject date_created status
        total_filings filings_in_last_30_days
      ].each do |key|
        assert results.keys.include?(key)
      end
    end
  end


end