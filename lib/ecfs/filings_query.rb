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

    def base_url
      "http://apps.fcc.gov/ecfs/comment_search/execute"
    end

    def get
      download_spreadsheet.rows
    end

    def mechanize_agent
      agent = Mechanize.new
      agent.follow_meta_refresh = true
      agent.pluggable_parser["application/vnd.ms-excel"] = ECFS::SpreadsheetParser

      agent
    end

    def download_spreadsheet
      agent = self.mechanize_agent
      page = agent.get(self.url)
      link_text = "\r\n    \t    \t    \tExport to Excel file\r\n    \t        \t"
      link = page.link_with(:text => link_text)
      
      agent.click(link)
    end
  end
end