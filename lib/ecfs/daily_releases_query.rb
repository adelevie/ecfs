require "pp"
require "pry"
require "mechanize"
require "ecfs/daily_release"

module ECFS

  class DailyReleasesQuery
    attr_accessor :day
    attr_accessor :month
    attr_accessor :year

    def initialize
    end
    
    def get
      url = "http://transition.fcc.gov/Daily_Releases/Daily_Business/#{@year}/db#{@month}#{@day}/"
      agent = Mechanize.new
      page = agent.get(url)
      
      links = page.search('a')
      links.shift
      
      ECFS::DailyRelease.new(links, url)
    end

  end
end
