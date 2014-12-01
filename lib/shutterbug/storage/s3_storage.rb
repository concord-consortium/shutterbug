module Shutterbug
  module Storage
    class S3Storage
      require 'fog'

      attr_reader :filename
      attr_reader :url

      PUT_URL_EXP_TIME = 300 # seconds

      def self.connect!
        Fog::Storage.new({
          :provider              => 'AWS',
          :aws_access_key_id     => Configuration.instance.s3_key,
          :aws_secret_access_key => Configuration.instance.s3_secret
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

      def self.write(filename)
        full_path = Configuration.instance.fs_path_for(filename)
        if self.fs_path_exists? full_path
          self.s3_bin.files.create(
            :key    => filename,
            :body   => File.open(full_path),
            :public => true)
        end
      end

      def self.fs_path_exists?(filename)
        File.exists?(filename)
      end

      def self.get_url(filename)
        # Manual URL construction, no proper method implemented in FOG.
        # But should be available soon, see: https://github.com/fog/fog/issues/3263
        "https://#{Configuration.instance.s3_bin}.s3.amazonaws.com/#{filename}"
      end

      def self.put_url(filename)
        expiry = (Time.now + PUT_URL_EXP_TIME).to_i
        headers = {}
        query = {
          'x-amz-acl' => 'public-read'
        }
        options = { path_style: true, query: query }
        self.connection.put_object_url(Configuration.instance.s3_bin, filename, expiry, headers, options)
      end

      def initialize(filename)
        @filename = filename
        @stream_file = S3Storage.write(filename)
        @url = @stream_file.public_url
      end
    end
  end
end