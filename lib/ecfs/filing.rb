require "ecfs/filings_query"
require "ecfs/document"

require "pry"

module ECFS
  class Filing < Hash
    attr_reader :documents

    def initialize(params={})
      self.merge!(params)
    end

    def fetch_documents!
      @documents = self["document_urls"].map do |url|
        ECFS::Document.new({
          "url" => url,
          "filing" => self
        })
      end

      self
    end

    def self.query
      ECFS::FilingsQuery.new(:typecast_results => true)
    end

  end
end