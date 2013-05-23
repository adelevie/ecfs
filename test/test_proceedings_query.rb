require "helper"
require "pp"

class TestProceedingsQuery < Test::Unit::TestCase

  def test_add_constraint
    proceedings_query = ECFS::ProceedingsQuery.new
    proceedings_query.eq("docket_number", "12-375")
    assert_equal proceedings_query.constraints, {"docket_number" => "12-375"}
  end

  def test_constraints_dictionary
    proceedings_query = ECFS::ProceedingsQuery.new
    dictionary        = proceedings_query.constraints_dictionary
    assert_equal Hash, dictionary.class
  end

  def test_query_string
    proceedings_query = ECFS::ProceedingsQuery.new
    proceedings_query.eq("docket_number", "12-375")
    proceedings_query.eq("subject", "phones")
    assert_equal proceedings_query.query_string, "name=12-375&subject=phones"
  end

  def test_url
    proceedings_query = ECFS::ProceedingsQuery.new
    proceedings_query.eq("bureau_code", "WC")
    proceedings_query.eq("subject", "phones")
    url = "http://apps.fcc.gov/ecfs/proceeding_search/execute?bureauCode=WC&subject=phones"
    assert_equal proceedings_query.url, url
  end

  def test_get_proceeding_info
    VCR.use_cassette('test_proceedings_query_test_get_proceeding_info') do
      proceedings_query = ECFS::ProceedingsQuery.new
      proceedings_query.eq("docket_number", "12-375")
      results = proceedings_query.get
      %w[
        bureau_name subject date_created status
        total_filings filings_in_last_30_days
      ].each do |key|
        assert results.keys.include?(key)
      end

      binding.pry
    end
  end

  def test_search_proceedings
    VCR.use_cassette('test_get_proceeding_search_results') do
      proceedings_query = ECFS::ProceedingsQuery.new
      proceedings_query.eq("bureau_code", "WC")
      proceedings_query.eq("page_number", "1")
      proceedings_query.eq("per_page", "100")
      results = proceedings_query.get
      %w[
        total_pages first_result
        last_result total_results
        current_page
      ].each do |key|
        assert results.keys.include?(key)
        assert results[key]
      end
    end
  end

end