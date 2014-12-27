require "helper"
require "pp"

class TestDailyReleases < MiniTest::Unit::TestCase

  def test_synopsis
    VCR.use_cassette('main_cassette') do
      releases = ECFS::DailyReleasesQuery.new.tap do |q|
        q.month = '12'
        q.day   = '17'
        q.year  = '2014'
      end.get
      
      assert releases.is_a?(ECFS::DailyRelease)
      assert releases.respond_to?(:pdfs)
      assert releases.respond_to?(:docxs)
      assert releases.respond_to?(:txts)      
    end
  end

end