require 'aws/s3'
module Shutterbug
  class S3File < BugFile

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
        return self.new(bug_file.filename)
      end
      return bug_file
    end

    def self.s3_bin
      return Configuration.instance.s3_bin
    end

    def self.exists?(filename)
      self.connect!
      AWS::S3::S3Object.exists?(filename, self.s3_bin)
    end

    def self.write(name, filename)
      stream = File.open(filename)
      self.connect!
      AWS::S3::S3Object.store(name, stream, s3_bin)
    end


    def self.find(path)
      self.new(path) if self.exists?(path)
      return nil
    end

    def self.fs_path_exists?(long_path)
      File.exists? long_path
    end

    def initialize(long_path)
      @filename = File.basename(long_path)
      unless Shutterbug::S3File.exists? @filename
        if Shutterbug::S3File.fs_path_exists? long_path
          Shutterbug::S3File.write(@filename, long_path)
        end
      end
    end

    def open
      @stream_file  ||= AWS::S3::S3Object.find(@filename, Shutterbug::S3File.s3_bin)
    end

    def each(&blk)
      AWS::S3::S3Object.stream(@filename, Shutterbug::S3File.s3_bin, {}, &blk)
    end
  end
end