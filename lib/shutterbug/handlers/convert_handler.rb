require 'stringio'

module Shutterbug
  module Handlers
    class ConvertHandler

      def self.config
        Configuration.instance
      end

      def self.regex
        /#{self.config.path_prefix}\/make_snapshot/
      end

      def handle(helper, req, env)
        response_text = convert(req).image_tag
        helper.response(response_text, 'text/plain')
      end

      def convert_quality(val, format)
        # Client sends quality between 0 and 1 (similar to .toDataURL() second argument).
        # This conversion tries to ensure that the size of the final image is similar to
        # .toDataURL() output with given quality settings.
        val = val.to_f
        case format
        when "png"
          val *= 10
        when "jpeg"
          val *= 100
        else
          val *= 100
        end
        # PhantomJS expects integer.
        val.to_i
      end

      def convert(req)
        html     = req.POST()['content'] || ""
        width    = req.POST()['width']   || 1000
        height   = req.POST()['height']  || 700
        css      = req.POST()['css']     || ""
        format   = req.POST()['format']  || "png"
        quality  = req.POST()['quality'] || 1
        quality  = convert_quality(quality, format)
        config   = self.class.config
        job = PhantomJob.new(config.base_url(req), html, css, width, height, format, quality)
        unless (cache_entry = config.cache_manager.find(job.cache_key))
          job.rasterize
          html_entry = Shutterbug::CacheManager::CacheEntry.new(job.html_file)
          png_entry  = Shutterbug::CacheManager::CacheEntry.new(job.png_file)
          html_entry.preview_url = png_entry.preview_url
          config.cache_manager.add_entry(html_entry)
          cache_entry = config.cache_manager.add_entry(png_entry)
        end
        # return the image tag
        return cache_entry
      end
    end
  end
end
