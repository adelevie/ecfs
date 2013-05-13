require "helper"
require "pp"

class TestFilingsQuery < Test::Unit::TestCase
  def test_add_constraint
    filings_query = ECFS::FilingsQuery.new
    filings_query.eq("docket_number", "12-375")
  end
end