# encoding: utf-8

module Shutterbug
  class Rackapp
    BASE_PATH      = "/shutterbug"

    CONVERT_PATH   = "#{BASE_PATH}/make_snapshot"
    CONVERT_REGEX  = /#{CONVERT_PATH}/

    PNG_PATH       = "#{BASE_PATH}/get_png"
    GET_PNG_REGEX  = /#{PNG_PATH}\/([^\/]+)/

    HTML_PATH      = "#{BASE_PATH}/get_html"
    GET_HTML_REGEX = /#{HTML_PATH}\/([^\/]+)/

    JS_PATH        = "#{BASE_PATH}/shutterbug.js"
    JS_REGEX       = /#{JS_PATH}$/

    def initialize app
      @app = app
      @shutterbug = Service.new()
      log "initialized"
    end

    def base_url(req)
      req.POST()['base_url'] ||  req.referrer || "#{req.scheme}://#{req.host_with_port}"
    end

    def do_convert(req)
      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""

      signature = @shutterbug.convert(base_url(req), html, css, width, height)
      response_url = "#{PNG_PATH}/#{signature}"
      response_text = "<img src='#{response_url}' alt='#{signature}'>"
      return good_response(response_text,'text/plain')
    end

    def call env
      req = Rack::Request.new(env)
      case req.path
      when CONVERT_REGEX
        do_convert(req)
      when GET_PNG_REGEX
        good_response(@shutterbug.get_png_file($1),'image/png')
      when GET_HTML_REGEX
        good_response(@shutterbug.get_html_file($1),'text/html')
      when JS_PATH
        good_response(@shutterbug.get_shutterbug_file, 'application/javascript')
      else
        skip(env)
      end
    end

    private
    def good_response(content, type, cache='no-cache')
      headers = {}
      headers['Content-Length'] = content.size.to_s
      headers['Content-Type']   = type
      headers['Cache-Control']  = 'no-cache'
      # content must be enumerable.
      content = [content] if content.kind_of? String
      return [200, headers, content]
    end

    def log(string)
      puts "★ shutterbug ➙ #{string}"
    end

    def skip(env)
      # call the applicaiton default
      @app.call env
    end

  end
end
