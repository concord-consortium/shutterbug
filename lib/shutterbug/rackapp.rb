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
      puts "initialized"
    end

    def log(string)
      puts string
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
      headers['Content-Length'] = response_text.size.to_s
      headers['Content-Type']   = 'text/plain'
      headers['Cache-Control']  = 'no-cache'
      return [200, headers, [response_text]]
    end

    def do_get_png(req)
      log 'do_get_png called'
      headers = {}
      sha =req.path.match(GET_PNG_REGEX)[1]
      svg_file = @shutterbug.get_png_file(sha)
      headers['Content-Length'] = svg_file.size.to_s
      headers['Content-Type']   = 'image/png'
      headers['Cache-Control']  = 'no-cache'
      return [200, headers, svg_file]
    end

    def do_get_html(req)
      log 'do_get_html called'
      headers = {}
      sha =req.path.match(GET_HTML_REGEX)[1]
      html_file = @shutterbug.get_html_file(sha)
      headers['Content-Length'] = html_file.size.to_s
      headers['Content-Type']   = 'text/html'
      headers['Cache-Control']  = 'no-cache'
      return [200, headers, html_file]
    end

    def do_get_shutterbug(req)
      log 'do_get_shutterbug called'
      headers = {}
      shutterbug_js = @shutterbug.get_shutterbug_file
      headers['Content-Length'] = shutterbug_js.size.to_s
      headers['Content-Type']   = 'application/javascript'
      headers['Cache-Control']  = 'no-cache'
      return [200, headers, shutterbug_js]
    end

    def hand_off(env)
      log 'calling app default'
      @app.call env
    end

    def call env
      req = Rack::Request.new(env)
      return do_convert(req)  if req.path =~ CONVERT_REGEX
      return do_get_png(req)  if req.path =~ GET_PNG_REGEX
      return do_get_html(req) if req.path =~ GET_HTML_REGEX
      return do_get_shutterbug(req) if req.path =~ JS_REGEX
      return hand_off(env)
    end
  end
end
