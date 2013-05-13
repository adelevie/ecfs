require "mechanize"

module ECFS

  class ProceedingsQuery
    attr_reader :constraints

    def initialize
      @constraints = {}
    end

    def eq(field, value)
      @constraints[field] = value
      self
    end

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

    def format_constraint(constraint)
      constraints_dictionary[constraint]
    end

    def query_string
      @constraints.keys.map do |constraint|
        format_constraint(constraint) + "=" + @constraints[constraint]
      end.join("&")
    end

    def url
      base = "http://apps.fcc.gov/ecfs/proceeding_search/execute"

      "#{base}?#{query_string}"
    end

    def get
      if @constraints["docket_number"]
        scrape_proceedings_page
      else
        scrape_results_page
      end
    end

    private

    def scrape_proceedings_page
      agent = Mechanize.new
      page = agent.get(url)
      container = []
      page.search("div").select do |d| 
        d.attributes["class"].nil? == false
      end.select do |d|
        d.attributes["class"].text == "wwgrp"
      end.each do |node|
        node.search("span").each do |span|
          search = span.search("label")
          pair = []
          if search.length > 0
            key = search.first.children.first.text.lstrip.rstrip.split(":")[0].gsub(" ", "_").downcase
            pair << key
          else
            value = span.text.lstrip.rstrip
            value.gsub!(",", "") if value.is_a?(String)
            pair << value
          end
          container << pair
        end
      end
      hash = {}
      container.each_slice(2) do |chunk|
        hash.merge!({chunk[0][0] => chunk[1][0]})
      end

      hash
    end

    def scrape_results_page
      raise "Parsing result pages is not yet supported."
    end

  end
end