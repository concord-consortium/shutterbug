require 'tmpdir'
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
    end

    def fs_path_for(filename)
      File.join(resource_dir,"phantom_#{filename}")
    end

    def url_prefix
      "#{uri_prefix}#{path_prefix}"
    end

    def convert_path
      "#{url_prefix}/make_snapshot"
    end

    def base_url(req)
      req.POST()['base_url'] ||  req.referrer || "#{req.scheme}://#{req.host_with_port}"
    end

    def storage
      use_s3? ? Storage::S3Storage : Storage::FileStorage
    end

    def use_s3?
      return (self.s3_bin && self.s3_key && self.s3_secret)
    end
  end
end