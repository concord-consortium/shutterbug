module Shutterbug
  module Handlers
    class FileHandler

      # relative url
      def self.path_prefix
        "#{Configuration.instance.path_prefix}/get_file"
      end

      # absolute url
      def self.uri_prefix
        "#{Configuration.instance.uri_prefix}#{self.path_prefix}"
      end

      def self.regex
        filename_matcher = "(([^\/|\.]+)\.?([^\/]+))?"
        /#{self.path_prefix}\/#{filename_matcher}/
      end

      def handle(helper, req, env)
        filename = self.class.regex.match(req.path)[1]
        if File.extname(filename) == ''
          filename += '.html'
        end
        file = Configuration.instance.storage.new(filename)
        helper.response(file.get_content, file.mime_type)
      end
    end
  end
end
