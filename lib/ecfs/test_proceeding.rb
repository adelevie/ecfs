require "helper"
require "pp"

class TestProceeding < Test::Unit::TestCase

  def test_find
    VCR.use_cassette('test_proceedings_query_test_get_proceeding_info') do

      proceeding = ECFS::Proceeding.find("12-375")

      %w[
        bureau_name subject date_created status
        total_filings filings_in_last_30_days
      ].each do |key|
        assert proceeding.keys.include?(key)
      end

      assert_equal proceeding.class, ECFS::Proceeding
    end
  end

  def test_search
    VCR.use_cassette('test_get_proceeding_search_results') do

      results = ECFS::Proceeding.query.tap do |q|
        q.bureau_code = "WC"
        q.page_number = "1"
        q.per_page    = "100"
      end.get

      results = proceedings_query.get

      %w[
        total_pages first_result
        last_result total_results
        current_page
      ].each do |key|
        assert results.keys.include?(key)
        assert results[key]
      end

      assert_equal results.class, ECFS::Proceeding::Array
    end
  end

end