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

      def get_options(req)
        opts = {}
        opts[:html]    = req.POST()['content']
        opts[:width]   = req.POST()['width']
        opts[:height]  = req.POST()['height']
        opts[:css]     = req.POST()['css']
        opts[:format]  = req.POST()['format']
        opts[:quality] = req.POST()['quality']
        return opts
      end

      def convert(req)
        config = self.class.config
        job = PhantomJob.new(config.base_url(req), get_options(req))
        unless (cache_entry = config.cache_manager.find(job.cache_key))
          job.rasterize
          html_entry = Shutterbug::CacheManager::CacheEntry.new(job.html_file)
          image_entry = Shutterbug::CacheManager::CacheEntry.new(job.image_file)
          html_entry.preview_url = image_entry.preview_url
          config.cache_manager.add_entry(html_entry)
          cache_entry = config.cache_manager.add_entry(image_entry)
        end
        # return the image tag
        return cache_entry
      end
    end
  end
end
