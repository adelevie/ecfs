require "helper"
require "pp"

class TestLargeProceeding < MiniTest::Unit::TestCase

  attr_accessor :results

  def test_throws_error
    VCR.use_cassette('bulk_cassette') do
      docket_number = "09-191"
      query = ECFS::Filing.query.tap do |q|
        q.docket_number = docket_number
      end
      assert_raises ECFS::TooManyFilingsError do
        results = query.get
      end
    end
  end

  def test_bulk_filings_query
    VCR.use_cassette('bulk_cassette') do
      docket_number = "11-109"
      query = ECFS::BulkFilingsQuery.new(docket_number)
      filings = query.get
      proceeding = ECFS::Proceeding.find(docket_number)

      assert_equal proceeding["total_filings"].to_i, filings.length
    end
  end

  #def test_bulk_filings_query_xxl
  #  VCR.use_cassette('bulk_cassette') do
  #    docket_number = "09-191"
  #    query = ECFS::BulkFilingsQuery.new(docket_number)
  #    filings = query.get
  #    proceeding = ECFS::Proceeding.find(docket_number)

  #    assert_equal proceeding["total_filings"].to_i, filings.length
  #  end
  #end


end