# encoding: utf-8
module Shutterbug
  class Rackapp

    DefaultHandlers = [
      Shutterbug::Handlers::ConvertHandler,
      Shutterbug::Handlers::DirectUploadHandler,
      Shutterbug::Handlers::FileHandler,
      Shutterbug::Handlers::ErrorTrigger
    ]

    def add_handler(klass)
      instance = klass.new
      log "adding handler for #{klass.regex} ➙ #{klass.name}"
      @handlers[klass.regex] = instance
    end

    def add_default_handlers
      DefaultHandlers.each { |h| add_handler(h) }
    end

    def initialize(app=nil, &block)
      @handlers = {}
      @config = Configuration.instance
      yield @config if block_given?
      @app = app
      add_default_handlers
      log "initialized"
    end

    def call(env)
      req    = Rack::Request.new(env)
      result = false
      @handlers.keys.each do |path_regex|
        if req.path =~ path_regex
          result = @handlers[path_regex].handle(self, req, env)
        end
      end
      result || skip(env)
    end

    def response(content, type, status=200, cachable=true)
      headers = {}
      size = content.respond_to?(:bytesize) ? content.bytesize : content.size
      headers['Content-Length'] = size.to_s
      headers['Content-Type']   = type
      headers['Cache-Control']  = 'no-cache' unless cachable
      content = [content] unless content.respond_to? 'each'
      return [status, headers, content]
    end

    def log(string)
      puts "★ shutterbug #{Shutterbug::VERSION} ➙ #{string}"
    end

    def skip(env)
      # call the applicaiton default
      @app.call(env) if @app
    end
  end
end
