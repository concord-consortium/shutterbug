module Shutterbug
  module CacheManager
    class CacheEntry
      attr_accessor :key
      attr_accessor :url
      attr_accessor :preview_url

      def initialize(storage)
        @key = storage.filename
        @url = storage.url
        @preview_url = storage.url
      end

      def image_tag
        "<img src='#{self.preview_url}' alt='#{self.preview_url}'>"
      end
    end
  end
end