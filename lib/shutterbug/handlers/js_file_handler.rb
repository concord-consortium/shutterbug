module Shutterbug
  module Handlers
    class JsFileHandler

      def self.config
        Configuration.instance
      end

      def self.js_path
        "#{self.config.url_prefix}/shutterbug.js"
      end

      def self.regex
        /#{self.config.path_prefix}\/shutterbug.js/
      end

      def initialize
        @javascript = File.read(js_file).gsub(/URL_PREFIX/, self.class.config.url_prefix)
      end

      def js_file
        File.join(File.dirname(__FILE__), "shutterbug.js")
      end

      def handle(helper, req, env)
        helper.response(@javascript, 'application/javascript')
      end
    end
  end
end
