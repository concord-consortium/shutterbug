require 'stringio'
module Shutterbug
  class Service

    def initialize(_config = Configuration.new)
      @file_cache = {}
      @config = _config
      @js_file = JsFile.new()
    end

    def convert(base_url, html, css="", width=1000, height=700)
      job = PhantomJob.new(base_url, html, css, width, height)
      key = job.cache_key
      unless (@file_cache[key])
        job.rasterize
        @file_cache[key] = {'html' => job.html_file, 'png' => job.png_file }
      end
      return key
    end

    def get_png_file(sha)
      file = @file_cache[sha]['png']
      file.open
      return file
    end

    def get_html_file(sha)
      file = @file_cache[sha]['html']
      file.open
      return file
    end

    def get_shutterbug_file
      file = @js_file
      file.open
      return file
    end
  end
end