module Shutterbug
  module Handlers
    class JsFileHandler

      def self.js_path
        "#{Configuration.instance.url_prefix}/shutterbug.js"
      end

      def regex
        /#{@config.path_prefix}\/shutterbug.js/
      end

      def js_file
        File.join(File.dirname(__FILE__),"shutterbug.js")
      end

      def initialize(_config=Configuration.instance())
        @config = _config
        @javascript = File.read(js_file).gsub(/URL_PREFIX/, @config.url_prefix)
      end

      def handle(helper, req, env)
        helper.good_response(@javascript, 'application/javascript')
      end
    end
  end
end