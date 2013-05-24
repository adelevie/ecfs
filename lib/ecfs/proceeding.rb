require "ecfs/proceedings_query"

require "pry"

module ECFS
  class Proceeding < Hash

    def initialize(params={})
      merge!(params)
    end

    def self.query
      ECFS::ProceedingsQuery.new(:typecast_results => true)
    end

    def self.find(docket_number)
      query.tap do |q|
        q.eq("docket_number", docket_number)
      end.get.merge!({"docket_number" => docket_number})
    end

    def fetch_info!
      merge!(ECFS::Proceeding.find(self["docket_number"]))

      self
    end

    def fetch_filings!
      filings = ECFS::Filing.query.tap do |q|
        q.docket_number = self["docket_number"]
      end.get
      merge!({"filings" => filings})

      self
    end

    class ResultSet < Hash

      def initialize(params={})
        params["next_page_number"] = (params["constraints"]["page_number"].to_i + 1).to_s
        merge!(params)
      end

      def next_query
        query = ECFS::Proceeding.query
        self["constraints"].each_pair do |key, value|
          query.eq(key, value) unless key == "page_number"
        end
        query.constraints["page_number"] = self["next_page_number"]

        query
      end

      def next
        next_query.get
      end

    end

  end
end