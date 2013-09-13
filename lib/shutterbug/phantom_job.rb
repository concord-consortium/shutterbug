module Shutterbug
  class PhantomJob

    attr_accessor :png_file
    attr_accessor :html_file

    def program
      @config.phantom_bin_path
    end

    def rasterize_js
      File.join(File.dirname(__FILE__),'rasterize.js')
    end

    def initialize(base_url, html, css="", width=1000, height=700)
      @base_url = base_url
      @html     = html
      @css      = css
      @width    = width
      @height   = height
      @config   = Configuration.instance
    end

    def cache_key
      @cache_key ||= Digest::SHA1.hexdigest("#{@html}#{@css}#{@base_url}")[0..10]
    end

    def document
      date = Time.now.strftime("%Y-%m-%d (%I:%M%p)")
      """
      <!DOCTYPE html>
      <html>
        <head>
          <base href='#{@base_url}'>
          <meta content='text/html;charset=utf-8' http-equiv='Content-Type'>
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

    def png_file_name
      "#{cache_key}.png"
    end

    def input_path
      @config.fs_path_for(html_file_name)
    end

    def output_path
      @config.fs_path_for(png_file_name)
    end

    def rasterize_cl
      %x[#{self.program} #{self.rasterize_js} #{self.input_path} #{self.output_path} #{@width}*#{@height}]
    end

    def rasterize
      File.open(input_path, 'w') do |f|
        f.write(document)
      end
      rasterize_cl()
      self.png_file  = @config.storage.new(png_file_name, Shutterbug::Handlers::FileHandlers::PngFile.new)
      self.html_file = @config.storage.new(html_file_name,  Shutterbug::Handlers::FileHandlers::HtmlFile.new)
    end
  end
end