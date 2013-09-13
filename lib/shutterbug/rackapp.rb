# encoding: utf-8
module Shutterbug
  class Rackapp

    class << self
      attr_accessor :handlers
      def add_handler(klass)
        instance = klass.new(Configuration.instance)
        log "adding handler for #{instance.regex} ➙ #{klass.name}"
        self.handlers[instance.regex] = instance
      end

      def log(string)
        puts "★ shutterbug #{Shutterbug::VERSION} ➙ #{string}"
      end
    end

    self.handlers = {}

    def initialize(app, &block)
      @config = Configuration.instance
      yield @config if block_given?
      @app = app
      [
        Shutterbug::Handlers::ConvertHandler ,
        Shutterbug::Handlers::JsFileHandler,
        Shutterbug::Handlers::FileHandlers::PngFile,
        Shutterbug::Handlers::FileHandlers::HtmlFile
      ].each { |h| Rackapp.add_handler(h) }

      log "initialized"
    end

    def call env
      req      = Rack::Request.new(env)
      result   = false
      Rackapp.handlers.keys.each do |path_regex|
        if req.path =~ path_regex
          result = Rackapp.handlers[path_regex].handle(self, req, env)
        end
      end
      result || skip(env)
    end

    def good_response(content, type, cachable=true)
      headers = {}
      headers['Content-Length'] = content.size.to_s
      headers['Content-Type']   = type
      headers['Cache-Control']  = 'no-cache' unless cachable
      # content must be enumerable.
      content = [content] if content.kind_of? String
      return [200, headers, content]
    end


    def log(info)
      self.class.log(info)
    end

    def skip(env)
      # call the applicaiton default
      @app.call env
    end

  end
end
