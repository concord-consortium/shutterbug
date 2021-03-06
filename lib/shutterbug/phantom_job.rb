module Shutterbug
  class PhantomJob
    attr_accessor :image_file
    attr_accessor :html_file

    def program
      @config.phantom_bin_path
    end

    def rasterize_js
      File.join(File.dirname(__FILE__),'rasterize.js')
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

    def initialize(base_url, options)
      @base_url = base_url
      @html     = options[:html]    || ""
      @css      = options[:css]     || ""
      @width    = options[:width]   || 1000
      @height   = options[:height]  || 700
      @format   = options[:format]  || "png"
      @quality  = options[:quality] || 1
      @quality  = convert_quality(@quality, @format)
      @config   = Configuration.instance
    end

    def cache_key
      @cache_key ||= Digest::SHA1.hexdigest("#{@html}#{@css}#{@base_url}#{@format}#{@quality}")[0..10]
    end

    def document
      date = Time.now.strftime("%Y-%m-%d (%I:%M%p)")
      """
      <!DOCTYPE html>
      <html>
        <head>
          <base href=\"#{@base_url}\">
          <meta content=\"text/html;charset=utf-8\" http-equiv=\"Content-Type\">
          <title>content from #{@base_url} #{date}</title>
          #{@css}
        </head>
        <body>
          #{@html}
        </body>
      </html>
      """
    end

    def html_file_name
      "#{cache_key}.html"
    end

    def image_file_name
      "#{cache_key}.#{@format}"
    end

    def input_path
      @config.fs_path_for(html_file_name)
    end

    def output_path
      @config.fs_path_for(image_file_name)
    end

    def rasterize_cl
      %x[#{self.program} --ignore-ssl-errors=true --ssl-protocol=any #{self.rasterize_js} #{self.input_path} #{self.output_path} #{@width}*#{@height} #{@quality}]
    end

    def rasterize
      File.open(input_path, 'w') do |f|
        f.write(document)
      end
      rasterize_cl()
      self.image_file = @config.storage.new(image_file_name)
      self.html_file = @config.storage.new(html_file_name)
    end
  end
end
