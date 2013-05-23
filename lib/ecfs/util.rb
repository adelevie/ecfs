module ECFS
  module Util
    def format_date(date)
      # input format 12/22/1988
      chunks = date.split("/")
      new_date = "#{chunks[2]}-#{chunks[0]}-#{chunks[1]}" # "22-12-1988"
      "#{new_date}T00:00:00.000Z" # dumb hack
    end
  end
end