module Shutterbug
  module Storage
    module FileStorage
      autoload :HtmlFile,  "shutterbug/storage/file_storage/html_file"
      autoload :PngFile,   "shutterbug/storage/file_storage/png_file"

      def self.handlers
        { 'html' => HtmlFile, 'png' => PngFile}
      end

      def self.handler_for(type)
        return self.handlers[type]
      end

      class Base
        attr_accessor :filename
        attr_accessor :config

        def self.find_for_sha(sha,types=['png','html'])
          results = {}
          types.each do |type|
            found  = self.find(@config.fs_path_for(sha,type))
            return nil unless found  # short circuit, we are missing something
            results[type] = found
          end
          return results
        end

        def self.find(path)
          return self.new(path) if File.exists?(path)
          return nil
        end

        def initialize(filename, _config=Configuration.instance())
          @filename = filename
          @config = _config
          register_handlers
        end

        def register_handlers
          # no default handlers
        end

        def get_content
          file = File.open(@filename, 'r')
          return file
        end
      end
    end
  end
end