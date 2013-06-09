require "helper"
require "pp"

class TestFiling < Test::Unit::TestCase

  def test_search
    VCR.use_cassette('main_cassette') do
      filings = ECFS::Filing.query.tap do |q|
        q.docket_number = "12-375" 
      end.get

      assert_equal filings.class, Array

      filing = filings.first

      assert_equal filing.class, ECFS::Filing
      assert_equal filing["name_of_filer"].class, String
      assert_equal filing["docket_number"], "12-375"
      assert_equal filing["lawfirm_name"].class, String
      assert_equal filing["date_received"].class, String
      assert_equal filing["date_posted"].class, String

      # checks if value is `true` or `false`--since Ruby does not have a Boolean type
      # http://stackoverflow.com/a/3033645/94154
      assert_equal !!filing["exparte"], filings.first["exparte"] 

      assert_equal filing["type_of_filing"].class, String
      assert_equal filing["document_urls"].class, Array

      assert_equal nil, filing.documents

      filing.fetch_documents!
      documents = filing.documents
      document = documents.first

      assert_equal Array, documents.class
      assert_equal ECFS::Document, document.class
      assert_equal String, document.full_text.class
      assert_equal Array, document.pages.class
      page = document.pages.first
      assert_equal ECFS::Document::Page, page.class
      assert_equal String, page.text.class
      assert_equal Fixnum, page.page_number.class

      #VCR.use_cassette('test_proceedings_query_test_get_proceeding_info') do
      #  binding.pry
      #end
    end
  end

end