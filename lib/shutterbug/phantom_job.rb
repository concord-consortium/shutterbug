module Shutterbug
  class PhantomJob

    attr_accessor :png_file
    attr_accessor :html_file

    def program
      'phantomjs'
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
    end

    def cache_key
      return @key || @key = Digest::SHA1.hexdigest("#{@html}#{@css}#{@base_url}")[0..10]
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

    def base_path
      "/tmp"
    end

    def infilename
      File.join(base_path,"phantom_#{cache_key}.html")
    end

    def outfilename
      File.join(base_path,"phantom_#{cache_key}.png")
    end

    def rasterize_cl
      %x[#{self.program} #{self.rasterize_js} #{self.infilename} #{self.outfilename} #{@width}*#{@height}]
    end

    def rasterize
      infile  = File.open(infilename, 'w') do |f|
        f.write(document)
      end
      rasterize_cl()
      self.png_file  = PngFile.new(outfilename)
      self.html_file = HtmlFile.new(infilename)
    end
  end
end