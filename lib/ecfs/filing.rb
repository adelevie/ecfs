require "ecfs/filings_query"

require "pry"

module ECFS
  class Filing < Hash

    def initialize(params={})
      self.merge!(params)
    end

    def self.query
      ECFS::FilingsQuery.new(:typecast_results => true)
    end

  end
end