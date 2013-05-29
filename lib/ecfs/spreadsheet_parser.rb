require "ecfs/util"
require "mechanize"
require "spreadsheet"
require "pry"

module ECFS
  class SpreadsheetParser < Mechanize::File
    include ECFS::Util
    attr_reader :rows

    def initialize(uri = nil, response = nil, body = nil, code = nil)
      super(uri, response, body, code)
      @body = body
      @rows = formatted_rows
    end

    private

    def file
      StringIO.new(@body)
    end

    def book
      Spreadsheet.open(file)
    end

    def sheet
      book.worksheet(0)
    end

    def unformatted_rows
      my_rows = []
      first = false
      sheet.each do |row|
        my_rows << row if first
        first = true
      end

      my_rows
    end

    def formatted_rows
      unformatted_rows.map do |row|
        row_to_hash(row)
      end
    end

    def row_to_hash(row)
      {
        "name_of_filer"  => row[1],
        "docket_number"  => row[0],
        "lawfirm_name"   => row[2],
        "date_received"  => format_date(row[3]),
        "date_posted"    => format_date(row[4]),
        "exparte"        => format_exparte(row[5]),
        "type_of_filing" => row[6],
        "document_urls"  => extract_urls_from_row(row)
      }
    end

    def extract_urls_from_row(row)
      indices = (7..row.length-1).to_a
      
      indices.map do |index|
        extract_url_from_row_and_index(row, index)
      end
    end

    def extract_url_from_row_and_index(row, index)
      text = row[index].data.split("id=")[1]
      
      "http://apps.fcc.gov/ecfs/document/view?id=#{extract_filing_id(text)}"
    end

    def extract_filing_id(txt)
      re1='(\\d+)'
      re=(re1)
      m = Regexp.new(re, Regexp::IGNORECASE)

      m.match(txt)[1]
    end

    def format_exparte(my_bool)
      return true  if my_bool == "Y"
      return false if my_bool == "N"
      return nil
    end

  end
end