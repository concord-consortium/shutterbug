module Shutterbug
  module Storage
    class S3Storage
      require 'fog'

      attr_accessor :filename
      attr_accessor :url
      attr_accessor :stream_file

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

      def self.create_bin
        self.connection.directories.create(
          :key    => Configuration.instance.s3_bin,
          :public => true)
      end

      def self.s3_bin
        @s3_bin ||= self.create_bin
      end

      def self.write(name, filename)
        full_path = Configuration.instance.fs_path_for(filename)
        if self.fs_path_exists? full_path
          self.s3_bin.files.create(
            :key    => name,
            :body   => File.open(full_path),
            :public => true)
        end
      end

      def self.find(path)
        self.s3_bin.files.get(path)
      end

      def self.fs_path_exists?(long_path)
        File.exists? long_path
      end

      def self.handler_for(type)
        return self.handlers[type]
      end

      def initialize(long_path, filetype)
        @filename = File.basename(long_path)
        @source = long_path
        @stream_file = S3Storage.write(@filename, long_path)
        @url = @stream_file.public_url
      end

      def get_content
        @stream_file.body
      end

      def size
        @stream_file.content_length
      end

      def redirect_s3
        return [301, {"Location" => self.url}, []]
      end

    end
  end
end