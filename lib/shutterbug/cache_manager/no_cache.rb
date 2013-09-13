module Shutterbug
  module CacheManager
    class NoCache
      attr_accessor :entries
      def initialize
        @entries = {}
      end

      def find(key)
        return @entries[key]
      end

      def add_entry(cache_entry)
        @entries[cache_entry.key] = cache_entry
      end

    end
  end
end