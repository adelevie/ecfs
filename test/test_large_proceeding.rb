require "helper"
require "pp"

class TestLargeProceeding < Test::Unit::TestCase
  def test_basic
    docket_number = "09-191"
    query = ECFS::Filing.query.tap do |q|
      q.docket_number = docket_number
    end
    assert_raise ECFS::TooManyFilingsError do
      results = query.get
    end
  end
end