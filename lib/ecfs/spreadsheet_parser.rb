require "mechanize"
require "spreadsheet"
require "pry"

module ECFS
  class SpreadsheetParser < Mechanize::File
    attr_reader :rows

    def initialize(uri = nil, response = nil, body = nil, code = nil)
      super(uri, response, body, code)
      @body = body
      extract_rows!
      format_rows!
    end

    private

    def extract_rows!
      book = Spreadsheet.open(StringIO.new(@body))
      sheet1 = book.worksheet 0
      @rows = []
      first = false
      sheet1.each do |row|
        @rows << row if first
        first = true
      end

      @rows
    end

    def format_rows!
      @rows.map! do |row|
        urls = []  
        indices = (7..row.length-1).to_a
        indices.each do |i|
          text = row[i].data.split("id=")[1]
          urls << "http://apps.fcc.gov/ecfs/document/view?id=#{extract_filing_id(text)}"
        end

        {
          'name_of_filer'  => row[1],
          'docket_number'  => row[0],
          'lawfirm_name'   => row[2],
          'date_received'  => format_date(row[3]),
          'date_posted'    => format_date(row[4]),
          'exparte'        => format_exparte(row[5]),
          'type_of_filing' => row[6],
          'document_urls'  => urls
        }
      end
    end

    def format_date(date)
      # input format 12/22/1988
      chunks = date.split("/")
      new_date = "#{chunks[2]}-#{chunks[0]}-#{chunks[1]}" # "22-12-1988"
      "#{new_date}T00:00:00.000Z" # dumb hack
    end

    def format_exparte(my_bool)
      return true  if my_bool == "Y"
      return false if my_bool == "N"
      return nil
    end

    def extract_filing_id(txt)
      re1='(\\d+)'
      re=(re1)
      m = Regexp.new(re, Regexp::IGNORECASE)
      if m.match(txt)
        int1 = m.match(txt)[1]
        return int1
      end
    end

  end # end class
end # end module