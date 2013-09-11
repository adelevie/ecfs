module ECFS
  module Util
    def format_iso_date(date)
      # input format 12/22/1988
      chunks = date.split("/")
      new_date = "#{chunks[2]}-#{chunks[0]}-#{chunks[1]}" # "22-12-1988"
      "#{new_date}T00:00:00.000Z" # dumb hack
    end

    def iso_date_to_simple_date(iso_date)
      chunks = iso_date.split("T")[0].split("-")
      "#{chunks[1]}-#{chunks[0]}-#{chunks[2]}"
    end
  end

end