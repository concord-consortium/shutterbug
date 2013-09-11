module Shutterbug
  class JsFile
    def initialize(_config=Configuration.instance())
      @config = _config
      @javascript = File.read(@config.js_file).gsub(/CONVERT_PATH/,@config.convert_path)
    end

    def register_handlers
      super
      Shutterbug::Rackapp.add_handler(@config.js_regex) do |helper, req, env|
        helper.good_response(@javascript, 'application/javascript')
      end
    end

  end
end