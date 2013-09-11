require "helper"
require "pp"

class TestProceeding < MiniTest::Unit::TestCase
  
  def test_find
    VCR.use_cassette('main_cassette') do
      proceeding = ECFS::Proceeding.find("12-375")
      %w[
        bureau_name subject date_created status
        total_filings filings_in_last_30_days
        docket_number
      ].each do |key|
        assert proceeding.keys.include?(key)
      end

      assert_equal ECFS::Proceeding, proceeding.class
    end
  end

  def test_search
    VCR.use_cassette('main_cassette') do

      proceedings = ECFS::Proceeding.query.tap do |q|
        q.bureau_code = "WC"
        q.page_number = "1"
        q.per_page    = "100"
      end.get

      %w[
        total_pages first_result last_result total_results
        current_page constraints fcc_url results
      ].each do |key|
        assert proceedings.keys.include?(key)
        assert proceedings[key]
      end

      assert_equal ECFS::Proceeding::ResultSet, proceedings.class
      assert_equal ECFS::ProceedingsQuery, proceedings.next_query.class
      next_proceedings = proceedings.next
      assert_equal ECFS::Proceeding::ResultSet, next_proceedings.class

      prison_phones = proceedings["results"].select {|p| p["docket_number"] == "12-375"}.first
      prison_phones.fetch_filings!

      assert_equal Array, prison_phones["filings"].class

      prison_phones = proceedings["results"].select {|p| p["docket_number"] == "12-375"}.first
      assert_equal ECFS::Proceeding, prison_phones.class
      fetched = prison_phones.fetch_info!
      assert_equal ECFS::Proceeding, prison_phones.class
      %w[
        bureau_name subject date_created status
        total_filings filings_in_last_30_days
      ].each do |key|
        assert prison_phones.keys.include?(key)
      end

    end
  end

end