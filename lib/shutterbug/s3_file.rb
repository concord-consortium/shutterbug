require 'aws/s3'
module Shutterbug
  class S3File

    def self.connect!
      unless AWS::S3::Base.connected?
        config = Configuration.instance
        AWS::S3::Base.establish_connection!(
          :access_key_id     => config.s3_key,
          :secret_access_key => config.s3_secret
        )
      end
    end

    def self.wrap(bug_file)
      if Configuration.instance.use_s3?
        self.connect!
        return self.new(bug_file)
      end
      return bug_file
    end

    def self.s3_bin
      return Configuration.instance.s3_bin
    end

    def self.exists?(filename)
      AWS::S3::S3Object.exists?(filename, self.s3_bin)
    end

    def self.write(name, filename)
      stream = File.open(filename)
      AWS::S3::S3Object.store(name, stream, s3_bin)
    end

    def initialize(bug_file)
      filename = bug_file.filename
      shortname = File.basename(filename)
      # TODO: Allow update / change?
      unless Shutterbug::S3File.exists? shortname
        Shutterbug::S3File.write(shortname, bug_file.filename)
      end
      @filename = shortname
    end

    def open
      @stream_file  ||= AWS::S3::S3Object.find(@filename, Shutterbug::S3File.s3_bin)
    end

    def each(&blk)
      AWS::S3::S3Object.stream(@filename, Shutterbug::S3File.s3_bin, {}, &blk)
    end

    def size
      @stream_file.size
    end
  end
end