module Shutterbug
  class BugFile
    def initialize(filename)
      @filename = filename
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