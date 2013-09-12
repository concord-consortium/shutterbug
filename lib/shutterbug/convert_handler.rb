require 'stringio'
module Shutterbug
  class ConvertHandler

    def initialize(_config = Configuration.instance)
      @config = _config
      Shutterbug::Rackapp.add_handler(@config.convert_regex) do |helper, req, env|
        response_text = convert(req).image_tag
        helper.good_response(response_text,'text/plain')
      end
    end

    def convert(req)
      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""
      job = PhantomJob.new(@config.base_url(req), html, css, width, height)
      unless (cache_entry = @config.cache_manager.find(job.cache_key))
        job.rasterize
        cache_entry = @config.cache_manager.add_job(job)
      end
      return cache_entry
    end
  end
end