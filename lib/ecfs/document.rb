require "pdf-reader"
require "open-uri"

module ECFS

  class Document
    attr_reader :pages
    attr_reader :filing

    def initialize(params={})
      @filing = params["filing"]
      @url = params["url"]
      @pages = []
      io     = open(@url)
      reader = PDF::Reader.new(io)
      reader.pages.each_with_index do |page, index|
        @pages << ECFS::Document::Page.new({
          "text" => page.text,
          "page_number" => index + 1
        })
      end
    end

    def full_text
      @pages.map {|p| p.text}.join(",")
    end

    class Page
      attr_reader :text
      attr_reader :page_number

      def initialize(params={})
        @text = params["text"]
        @page_number = params["page_number"]
      end

      def to_s
        "#<ECFS::Document::Page @text=#{@text.class}, @page_number=#{@page_number}>"
      end

      def inspect
        self.to_s
      end
    end
  end

end