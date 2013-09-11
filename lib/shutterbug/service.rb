require 'stringio'
module Shutterbug
  class Service

    def initialize(_config = Configuration.instance)
      @file_cache = {}
      @config = _config
      Shutterbug::Rackapp.add_handler(@config.convert_regex) do |helper, req, env|
        helper.log("trying to convert")
        html     = req.POST()['content']  ||  ""
        width    = req.POST()['width']    || 1000
        height   = req.POST()['height']   ||  700
        css      = req.POST()['css']      ||  ""

        cache_entry   = self.convert(@config.base_url(req), html, css, width, height)
        response_text = cache_entry.image_tag
        helper.good_response(response_text,'text/plain')
      end
    end

    def convert(base_url, html, css="", width=1000, height=700)
      job = PhantomJob.new(base_url, html, css, width, height)
      unless (cache_entry = @config.cache_manager.find(job.cache_key))
        job.rasterize
        cache_entry = @config.cache_manager.add_job(job)
      end
      return cache_entry
    end

    def find_in_cache(sha)
      return Configuration.cache_manager.find(sha)
    end

  end
end