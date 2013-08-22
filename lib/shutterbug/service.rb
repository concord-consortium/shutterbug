require 'stringio'
module Shutterbug
  class Service

    def initialize(_config = Configuration.instance)
      @file_cache = {}
      @config = _config
      @js_file = JsFile.new()
    end

    def convert(base_url, html, css="", width=1000, height=700)
      job = PhantomJob.new(base_url, html, css, width, height)
      key = job.cache_key
      unless (find_in_cache(key))
        job.rasterize
        @file_cache[key] = {'html' => job.html_file, 'png' => job.png_file }
      end
      return key
    end

    def check_filesystem(sha)
      service = Shutterbug::BugFile
      service = Shutterbug::S3File if @config.use_s3?
      cache_entry = service.find_for_sha(sha, ['html','png'])
      @file_cache[sha] = cache_entry if cache_entry
      cache_entry
    end

    def find_in_cache(sha)
      @file_cache[sha] || check_filesystem(sha)
    end

    def get_png_file(sha)
      file = find_in_cache(sha)['png']
      file.open
      return file
    end

    def get_html_file(sha)
      file = find_in_cache(sha)['html']
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