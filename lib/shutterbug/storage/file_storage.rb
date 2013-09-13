module Shutterbug
  module Storage
    class FileStorage
      attr_accessor :filename
      attr_accessor :config
      attr_accessor :url

      def initialize(filename, file_handler)
        @filename = Configuration.instance.fs_path_for(filename)
        @url = file_handler.urlify(filename)
      end

      def get_content
        file = File.open(@filename, 'r')
        return file
      end

    end
  end
end