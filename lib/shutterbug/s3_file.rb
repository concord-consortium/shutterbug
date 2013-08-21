require 'fog'
module Shutterbug
  class S3File < BugFile

    def self.connect!
      Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => Configuration.instance.s3_key,
        :aws_secret_access_key    => Configuration.instance.s3_secret
      })
    end

    def self.connection
      @connection ||= self.connect!
    end

    def self.wrap(bug_file)
      if Configuration.instance.use_s3?
        return self.new(bug_file.filename)
      end
      return bug_file
    end

    def self.create_bin
      self.connection.directories.create(
        :key    => Configuration.instance.s3_bin,
        :public => true)
    end

    def self.s3_bin
      @s3_bin ||= self.create_bin
    end

    def self.exists?(filename)
      self.s3_bin.files.get(filename) != nil
    end

    def self.write(name, filename)
      if self.fs_path_exists? filename
        self.s3_bin.files.create(
          :key    => name,
          :body   => File.open(filename),
          :public => true)
      end
    end


    def self.find(path)
      self.s3_bin.files.get(path)
    end

    def self.fs_path_exists?(long_path)
      File.exists? long_path
    end

    def initialize(long_path)
      @filename = File.basename(long_path)
      unless Shutterbug::S3File.exists? @filename
        Shutterbug::S3File.write(@filename, long_path)
      end
    end

    def open
      @stream_file = Shutterbug::S3File.s3_bin.files.get(@filename)
    end

    def each(&blk)
      yield @stream_file.body
    end

    def size
      @stream_file.content_length
    end
  end
end