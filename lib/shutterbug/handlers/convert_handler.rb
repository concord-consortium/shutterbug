require 'stringio'
module Shutterbug
  module Handlers
    class ConvertHandler

      def initialize(_config = Configuration.instance)
        @config = _config
      end

      def regex
        /#{@config.path_prefix}\/make_snapshot/
      end

      def handle(helper, req, env)
        response_text = convert(req).image_tag
        helper.good_response(response_text,'text/plain')
      end

      def convert(req)
        html     = req.POST()['content']  ||  ""
        width    = req.POST()['width']    || 1000
        height   = req.POST()['height']   ||  700
        css      = req.POST()['css']      ||  ""
        job = PhantomJob.new(@config.base_url(req), html, css, width, height)
        unless (cache_entry = @config.cache_manager.find(job.cache_key))
          job.rasterize
          html_entry = Shutterbug::CacheManager::CacheEntry.new(job.html_file)
          png_entry  = Shutterbug::CacheManager::CacheEntry.new(job.png_file)
          html_entry.preview_url = png_entry.preview_url
          @config.cache_manager.add_entry(html_entry)
          cache_entry = @config.cache_manager.add_entry(png_entry)
        end
        # return the image tag
        return cache_entry
      end
    end
  end
end