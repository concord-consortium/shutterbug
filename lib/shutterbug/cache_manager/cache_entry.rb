module Shutterbug
  module CacheManager
    class CacheEntry
      attr_accessor :key
      attr_accessor :html
      attr_accessor :png

      def initialize(job)
        @urls = {}
        job && @key  = job.cache_key
        job && @html = job.html_url
        job && @png  = job.png_url
      end

      def image_tag
        "<img src='#{self.png}' alt='#{self.key}'>"
      end
    end
  end
end