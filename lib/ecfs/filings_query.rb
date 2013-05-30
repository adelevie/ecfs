require "pp"
require "mechanize"
require "spreadsheet"
require "ecfs/spreadsheet_parser"
require "pry"

module ECFS

  class FilingsQuery
    include ECFS::Query

    def constraints_dictionary
      {
        "docket_number"               => "proceeding",
        "applicant"                   => "applicant",
        "lawfirm"                     => "lawfirm",
        "author"                      => "author",
        "posted_after"                => "disseminated.minDate",
        "posted_before"               => "disseminated.maxDate",
        "received_after"              => "recieved.minDate",
        "received_before"             => "recieved.maxDate",
        "comment_period_after"        => "dateCommentPeriod.minDate",
        "comment_period_before"       => "dateCommentPeriod.maxDate",
        "reply_comment_period_after"  => "dateReplyComment.minDate",
        "reply_comment_period_before" => "dateReplyComment.maxDate",
        "city"                        => "address.city",
        "state_code"                  => "address.state.stateCd",
        "zip"                         => "address.zip",
        "da_number"                   => "daNumber",
        "file_number"                 => "fileNumber",
        "bureau_id_number"            => "bureauIdentificationNumber",
        "report_number"               => "reportNumber",
        "submission_type_id"          => "submissionTypeId",
        "exparte"                     => "__checkbox_exParte"
      }
    end

    self.new.constraints_dictionary.keys.each do |key|
      class_eval do

        define_method("#{key}=") do |value|
          eq(key, value)
        end

        define_method(key) do
          @constraints[key]
        end

      end
    end

    def base_url
      "http://apps.fcc.gov/ecfs/comment_search/execute"
    end

    def get
      download_spreadsheet!
      @typecast_results ? @rows.map {|row| row_to_filing(row)} : @rows
    end

    def row_to_filing(row)
      ECFS::Filing.new(row)
    end

    def mechanize_agent
      Mechanize.new.tap do |agent|
        agent.follow_meta_refresh = true
        agent.pluggable_parser["application/vnd.ms-excel"] = ECFS::SpreadsheetParser
      end
    end

    def download_spreadsheet!
      agent = mechanize_agent
      link_text = "\r\n    \t    \t    \tExport to Excel file\r\n    \t        \t"
      link = agent.get(url).link_with(:text => link_text)

      @rows = agent.click(link).rows
    end
  end
end