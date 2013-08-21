module Shutterbug
  class BugFile
    attr_accessor :filename
    def initialize(filename)
      @filename = filename
    end

    def self.find_for_sha(sha,types=['png','html'])
      results = {}
      failed = false
      types.each do |type|
        found  = self.find(Configuration.instance.fs_path_for(sha,type))
        return nil unless found  # short circuit, we are missing something
        results[type] = found
      end
      return results
    end

    def self.find(path)
      return self.new(path) if File.exists?(path)
      return nil
    end

    def open
      @stream_file = File.open(@filename, 'r')
      @stream_file.rewind
    end

    def each(&blk)
      @stream_file.each(&blk)
    ensure
      @stream_file.close
    end

    def size
      @stream_file.size
    end
  end
end