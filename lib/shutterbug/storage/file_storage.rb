module Shutterbug
  module Storage
    class FileStorage
      attr_accessor :filename
      attr_accessor :config
      attr_accessor :url

      def initialize(filename, file_class)
        @filename = Configuration.instance.fs_path_for(filename)
        @url = file_class.urlify(filename)
      end

      def get_content
        file = File.open(@filename, 'r')
        return file
      end

    end
  end
end