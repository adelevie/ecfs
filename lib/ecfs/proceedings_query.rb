require "mechanize"
require "ecfs/util"

module ECFS
  class ProceedingsQuery
    include ECFS::Query
    include ECFS::Util

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
      "http://apps.fcc.gov/ecfs/proceeding_search/execute"
    end

    def get
      if @constraints["docket_number"]
        # if docket_number is given along with other constraints, the other constraints will be ignored.
        warn "Constraints other than `docket_number` will be ignored." if @constraints.keys.length > 1
        
        return scrape_proceeding_page! unless @typecast_results
        results = ECFS::Proceeding.new(scrape_proceeding_page!)
      else
        return scrape_results_page unless @typecast_results
        results = ECFS::Proceeding::ResultSet.new(scrape_results_page)
      end

      results
    end


    private

    def mechanize_page
      Mechanize.new.get(url)
    end

    def scrape_proceeding_page!
      container_to_hash do
        mechanize_page.search("div").select do |div| 
          div.attributes["class"].nil? == false
        end.select do |div|
          div.attributes["class"].text == "wwgrp"
        end.map do |node|
          search_node(node)
        end
      end
    end

    def container_to_hash(&block)
      hash = {}
      block.call.flatten!.each_slice(2) do |chunk|
        hash[chunk[0]] = chunk[1]
      end

      hash
    end

    def search_node(node)
      node.search("span").map do |span|
        search = span.search("label")
        key_or_value_from_search_and_span(search, span)
      end
    end

    def key_or_value_from_search_and_span(search, span)
      search.length > 0 ? key_from_search(search) : value_from_span(span)
    end

    def key_from_search(search)
      format_key_text(search.first.children.first.text)
    end

    def format_key_text(key_text)
      key_text.lstrip!.rstrip!
      key_text = key_text.split(":")[0]
      key_text.gsub!(" ", "_")
      key_text.downcase!
    end

    def value_from_span(span)
      value = text_from_span(span)
      value.gsub!(",", "") if value.is_a?(String)

      value
    end

    def text_from_span(span)
      span.text.lstrip.rstrip
    end

    def scrape_results_page
      page   = mechanize_page
      banner = extract_banner_from_page(page)

      {
        "constraints"   => @constraints,
        "fcc_url"       => url,
        "current_page"  => current_page,
        "total_pages"   => total_pages_from_page(page),
        "first_result"  => first_from_banner(banner),
        "last_result"   => last_from_banner(banner),
        "total_results" => total_from_banner(banner),
        "results"       => proceedings_from_page(page)
      }
    end

    def current_page
      self.constraints["page_number"].gsub(",","").to_i
    end

    def proceedings_from_page(page)
      extract_table_rows_from_page(page).map do |row|
        row_to_proceeding(row)
      end
    end

    def extract_table_rows_from_page(page)
      xpath = "//*[@id='yui-main']/div/div[2]/table/tbody/tr[2]/td/table/tbody"
      page.search(xpath).children
    end

    def first_from_banner(banner)
      extract_from_banner(banner, 1)
    end

    def last_from_banner(banner)
      extract_from_banner(banner, 3)
    end

    def total_from_banner(banner)
      extract_from_banner(banner, 5)
    end

    def extract_banner_from_page(page)
      xpath = "//*[@id='yui-main']/div/div[2]/table/tbody/tr[2]/td/span[1]"
      page.search(xpath).text.tap do |t|
        t.lstrip!
        t.rstrip!
      end.split("Modify Search")[0].rstrip.split  
    end

    def extract_from_banner(banner, index)
      banner[index].gsub(",", "").to_i
    end

    def total_pages_from_page(page)
      page.link_with(:text => "Last").attributes.first[1].split("pageNumber=")[1].gsub(",","").to_i
    end

    def row_to_proceeding(row)
      ECFS::Proceeding.new(row_to_hash(row))
    end

    def row_to_hash(row)
      {
        "docket_number"           => docket_number_from_row(row),
        "bureau"                  => bureau_from_row(row),
        "subject"                 => subject_from_row(row),
        "filings_in_last_30_days" => filings_in_last_30_days_from_row(row)
      }
    end

    def bureau_from_row(row)
      row.children[2].children.children.first.text.lstrip.rstrip
    end

    def docket_number_from_row(row)
      row.children[0].children[1].attributes["href"].value.split("name=")[1].rstrip
    end

    def subject_from_row(row)
      row.children[4].children.text.lstrip.rstrip
    end

    def filings_in_last_30_days_from_row(row)
      row.children[6].children.first.text.lstrip.rstrip.to_i
    end
    #####

  end
end