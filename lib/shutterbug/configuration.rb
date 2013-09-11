module Shutterbug
  class Configuration

    attr_accessor :uri_prefix
    attr_accessor :path_prefix
    attr_accessor :resource_dir
    attr_accessor :phantom_bin_path
    attr_accessor :s3_bin
    attr_accessor :s3_key
    attr_accessor :s3_secret
    attr_accessor :cache_manager
    attr_accessor :storage

    def self.instance(opts={})
      return @instance || @instance = self.new(opts)
    end

    def initialize(opts={})
      self.uri_prefix       = opts[:uri_prefix]       || ""
      self.path_prefix      = opts[:path_prefix]      || "/shutterbug"
      self.resource_dir     = opts[:resource_dir]     || Dir.tmpdir
      self.phantom_bin_path = opts[:phantom_bin_path] || "phantomjs"
      self.s3_bin           = opts[:s3_bin]
      self.s3_key           = opts[:s3_key]
      self.s3_secret        = opts[:s3_secret]
      self.cache_manager    = opts[:cache_manager]    || Shutterbug::CacheManager::NoCache.new
      self.storage          = Storage::FileStorage
    end

    def handler_for(type)
      self.storage.handler_for(type)
    end

    def fs_path_for(key,extension)
      File.join(resource_dir,"phantom_#{key}.#{extension}")
    end

    def js_path
      "#{uri_prefix}#{path_prefix}/shutterbug.js"
    end

    def js_regex
      /#{path_prefix}\/shutterbug.js/
    end

    def js_file
      File.join(File.dirname(__FILE__),"shutterbug.js")
    end

    def convert_path
      "#{uri_prefix}#{path_prefix}/make_snapshot"
    end

    def convert_regex
      /#{path_prefix}\/make_snapshot/
    end

    def png_path(sha='')
      entry = cache_manager.find(sha)
      if (entry && entry.respond_to?(:public_url))
        return entry.public_url
      end
      return "#{uri_prefix}#{path_prefix}/get_png/#{sha}"
    end

    def png_regex
      /#{path_prefix}\/get_png\/([^\/]+)/
    end

    def html_path(sha='')
      "#{uri_prefix}#{path_prefix}/get_html/#{sha}"
    end

    def html_regex
      /#{path_prefix}\/get_html\/([^\/]+)/
    end

    def base_url(req)
      req.POST()['base_url'] ||  req.referrer || "#{req.scheme}://#{req.host_with_port}"
    end

    def use_s3?
      return (self.s3_bin && self.s3_key && self.s3_secret)
    end
  end
end