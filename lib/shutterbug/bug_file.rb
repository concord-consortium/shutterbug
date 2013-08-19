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
        failed = !found
        results[type] = self.find(Configuration.instance.fs_path_for(sha,type))
      end
      return results unless failed
      return nil
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