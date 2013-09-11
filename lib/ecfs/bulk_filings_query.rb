module ECFS
  class BulkFilingsQuery
    attr_accessor :results

    def initialize(docket_number)
      @docket_number = docket_number
    end

    def get
      make_query(@docket_number)
    end

    def get_midpoint(start_date, end_date)
      start_date       = start_date.split("/")
      start_date_month = start_date[0].to_i
      start_date_day   = start_date[1].to_i
      start_date_year  = start_date[2].to_i
      docket_started   = Date.new(start_date_year, start_date_month, start_date_day)

      e = end_date.split("/").map(&:to_i).reverse
      difference      = (Date.new(e[0], e[2], e[1]) - docket_started).to_i
      half_difference = difference/2
      midpoint        = (docket_started + half_difference).to_s.gsub("-", "/")

      midpoint.split("/").reverse.join("/")
    end

    def make_query(docket_number, posted_after=false, posted_before=false)

      if @results.nil?
        @results = []
      end

      query = ECFS::Filing.query.tap do |q|
        q.docket_number = docket_number
        q.posted_after  = posted_after  if posted_after
        q.posted_before = posted_before if posted_before
      end

      begin
        @results << query.get
      rescue ECFS::TooManyFilingsError
        unless posted_after
          posted_after = ECFS::Proceeding.find(docket_number)["date_created"] 
        end
        unless posted_before
          today = Date.today.to_s.split("-")
          posted_before = today[1] + "/" + today[2] + "/" + today[0]
        end
        midpoint = get_midpoint(posted_after, posted_before).split("/")
        formatted_midpoint = midpoint[1] + "/" + midpoint[0] + "/" + midpoint[2]

        make_query(docket_number, formatted_midpoint, posted_before)
        make_query(docket_number, posted_after, formatted_midpoint)
      end

      @results.flatten!

      @results
    end

  end

end