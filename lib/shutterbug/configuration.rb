module Shutterbug
  class Configuration

    attr_accessor :url_base
    attr_accessor :resource_dir

    def self.instance(opts={})
      return @instance || @instance = self.new(opts)
    end

    def initialize(opts={})
      self.url_base     = opts[:url_base]     || "/shutterbug"
      self.resource_dir = opts[:resource_dir] || Dir.tmpdir
    end

    def js_path
      "#{url_base}/shutterbug.js"
    end
    def js_regex
      /#{js_path}/
    end

    def js_file
      File.join(File.dirname(__FILE__),"shutterbug.js")
    end

    def convert_path
      "#{url_base}/make_snapshot"
    end
    def convert_regex
      /#{convert_path}/
    end

    def png_path(sha='')
      "#{url_base}/get_png/#{sha}"
    end
    def png_regex
      /#{png_path}([^\/]+)/
    end

    def html_path(sha='')
      "#{url_base}/get_html/#{sha}"
    end
    def html_regex
      /#{html_path}([^\/]+)/
    end

    def base_url(req)
      req.POST()['base_url'] ||  req.referrer || "#{req.scheme}://#{req.host_with_port}"
    end
  end
end