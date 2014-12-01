module Shutterbug
  module Storage
    class FileStorage
      attr_reader :filename
      attr_reader :url

      MIME_TYPES = {
        '.png'  => 'image/png',
        '.jpeg' => 'image/jpeg',
        '.jpg'  => 'image/jpeg',
        '.html' => 'text/html',
        ''      => 'text/html'
      }

      def self.get_url(name)
        "#{Handlers::FileHandler.uri_prefix}/#{name}"
      end

      def initialize(filename)
        @filename = Configuration.instance.fs_path_for(filename)
        @url = self.class.get_url(filename)
      end

      def get_content
        File.open(@filename, 'r')
      end

      def mime_type
        MIME_TYPES[File.extname(@filename)]
      end
    end
  end
end
