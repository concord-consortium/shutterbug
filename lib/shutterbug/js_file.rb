module Shutterbug
  class JsFile   < BugFile
    def initialize(_config=Configuration.new())
      @config = _config
      @javascript = File.read(@config.js_file).gsub(/CONVERT_PATH/,@config.convert_path)
    end
    def open
      @stream_file = StringIO.new(@javascript)
    end
  end
end