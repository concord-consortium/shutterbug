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

      def add_job(job)
        new_entry = Shutterbug::CacheManager::CacheEntry.new(job)
        @entries[new_entry.key] = new_entry
      end

    end
  end
end