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


    def do_convert(req)
      log 'do_convert called'
      headers = {}

      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""
      base_url = req.POST()['base_url'] ||  req.referrer || "#{req.scheme}://#{req.host_with_port}"

      log "BASE: #{base_url}"

      signature = @shutterbug.convert(base_url, html, css, width, height)
      response_url = "#{PNG_PATH}/#{signature}"
      response_text = "<img src='#{response_url}' alt='#{signature}'>"
      return good_response(response_text,'text/plain')
    end

    def do_get_png(req)
      log 'do_get_png called'
      sha =req.path.match(GET_PNG_REGEX)[1]
      png_file = @shutterbug.get_png_file(sha)
      good_response(png_file, 'image/png')
    end

    def do_get_html(req)
      log 'do_get_html called'
      sha =req.path.match(GET_HTML_REGEX)[1]
      html_file = @shutterbug.get_html_file(sha)
      good_response(html_file, 'text/html')
    end

    def do_get_shutterbug(req)
      log 'do_get_shutterbug called'
      shutterbug_js = @shutterbug.get_shutterbug_file
      good_response(shutterbug_js, 'application/javascript')
    end

    def call env
      req = Rack::Request.new(env)
      return do_convert(req)  if req.path =~ CONVERT_REGEX
      return do_get_png(req)  if req.path =~ GET_PNG_REGEX
      return do_get_html(req) if req.path =~ GET_HTML_REGEX
      return do_get_shutterbug(req) if req.path =~ JS_REGEX
      return skip(env)
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
      log 'calling app default'
      @app.call env
    end

  end
end
