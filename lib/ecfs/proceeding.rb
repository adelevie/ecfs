require "ecfs/proceedings_query"

module ECFS
  class Proceeding
    def self.find(docket_number)
      ECFS::ProceedingsQuery.new.tap do |q|
        q.eq("docket_number", docket_number)
      end.get
    end
  end 
end