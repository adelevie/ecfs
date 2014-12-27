require 'pry'

module ECFS
  class DailyRelease
    attr_reader :pdfs
    attr_reader :txts
    attr_reader :docxs
    
    def initialize(links, query_url)
      @query_url = query_url
      @links     = links
      @pdfs      = find_links_by_type('pdf')
      @txts      = find_links_by_type('txt')
      @docxs     = find_links_by_type('docx')
    end
    
    private
    
    def find_links_by_type(type)
      @links.select do |link|
        link.attributes["href"].value.end_with?(".#{type}")
      end.map do |link|
        link_to_s(link)
      end
    end
    
    def link_to_s(link)
      href_val = link.attributes["href"].value
      {
        title: href_val,
        url: @query_url + href_val
      }
    end
  end
end