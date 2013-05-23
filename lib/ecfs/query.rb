module ECFS
  module Query
    attr_reader :constraints

    def initialize(params={})
      @typecast_results = params[:typecast_results]
      @constraints = {}
    end

    def eq(field, value)
      @constraints[field] = value
      self
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
      "#{base_url}?#{query_string}"
    end

  end
end