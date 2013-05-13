module ECFS
  class FilingsQuery < ECFS::Query
    def constraints_dictionary
      {
        "docket_number"  => "name",
        "bureau_code"    => "bureauCode",
        "subject"        => "subject",
        "bureau_id"      => "bureauIdentificationNumber",
        "applicant"      => "application",
        "filed_by"       => "filedBy",
        "recent_filings" => "__checkbox_recentFilingsRequired",
        "open_status"    => "openStatus",
        "created_after"  => "created.minDate",
        "created_before" => "created.maxDate",
        "closed_after"   => "closed.minDate",
        "closed_before"  => "closed.maxDate",
        "callsign"       => "callsign",
        "channel"        => "channel",
        "rule_section"   => "ruleSection",
        "page_number"    => "pageNumber",
        "per_page"       => "pageSize"
      }
    end

    def base_url
      "http://apps.fcc.gov/ecfs/proceeding_search/execute"
    end

    def get

    end
  end
end