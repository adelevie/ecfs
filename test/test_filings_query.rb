require "helper"
require "pp"

class TestFilingsQuery < MiniTest::Unit::TestCase
  
  def test_add_constraint
    filings_query = ECFS::FilingsQuery.new
    filings_query.eq("docket_number", "12-375")
    assert_equal filings_query.constraints, {"docket_number" => "12-375"}
  end

  def test_constraints_dictionary
    filings_query = ECFS::FilingsQuery.new
    dictionary    = filings_query.constraints_dictionary
    assert_equal Hash, dictionary.class
  end

  def test_query_string
    filings_query = ECFS::FilingsQuery.new
    filings_query.eq("docket_number", "12-375")
    filings_query.eq("lawfirm", "FCC")
    assert_equal filings_query.query_string, "proceeding=12-375&lawfirm=FCC"
  end

  def test_url
    filings_query = ECFS::FilingsQuery.new
    filings_query.eq("docket_number", "12-375")
    filings_query.eq("lawfirm", "FCC")
    url = "http://apps.fcc.gov/ecfs/comment_search/execute?proceeding=12-375&lawfirm=FCC"
    assert_equal filings_query.url, url
  end

  def test_get
    VCR.use_cassette('main_cassette') do
      filings_query = ECFS::FilingsQuery.new
      filings_query.eq("docket_number", "12-375")
      rows = filings_query.get
      assert_equal rows.class, Array
      assert_equal rows.first.class, Hash
      assert_equal rows.first["name_of_filer"].class, String
      assert_equal rows.first["docket_number"], "12-375"
      assert_equal rows.first["lawfirm_name"].class, String
      assert_equal rows.first["date_received"].class, String
      assert_equal rows.first["date_posted"].class, String

      # checks if value is `true` or `false`--since Ruby does not have a Boolean type
      # http://stackoverflow.com/a/3033645/94154
      assert_equal !!rows.first["exparte"], rows.first["exparte"] 

      assert_equal rows.first["type_of_filing"].class, String
      assert_equal rows.first["document_urls"].class, Array
    end
  end
end