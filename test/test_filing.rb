require "helper"
require "pp"

class TestFiling < Test::Unit::TestCase

  def test_search
    VCR.use_cassette('test_filings_query_test_get') do
      filings = ECFS::Filing.query.tap do |q|
        q.docket_number = "12-375" 
      end.get

      assert_equal filings.class, Array
      assert_equal filings.first.class, ECFS::Filing
      assert_equal filings.first["name_of_filer"].class, String
      assert_equal filings.first["docket_number"], "12-375"
      assert_equal filings.first["lawfirm_name"].class, String
      assert_equal filings.first["date_received"].class, String
      assert_equal filings.first["date_posted"].class, String

      # checks if value is `true` or `false`--since Ruby does not have a Boolean type
      # http://stackoverflow.com/a/3033645/94154
      assert_equal !!filings.first["exparte"], filings.first["exparte"] 

      assert_equal filings.first["type_of_filing"].class, String
      assert_equal filings.first["document_urls"].class, Array

    end
  end

end