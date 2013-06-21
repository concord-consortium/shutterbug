require 'rack'
describe Shutterbug::Rackapp do
  let(:service) { mock :service }
  let(:app)     { mock :app     }
  let(:post_data) do
    {
      'content'  => "<div class='foo'>foo!</div>",
      'width'    => 1000,
      'height'   => 700,
      'css'      => "",
      'base_url' => "http://localhost:8080/"
    }
  end
  subject { Shutterbug::Rackapp.new(app) }

  before(:each) do
    Shutterbug::Service.stub!(:new => service)
  end

  describe "#do_convert" do
    let(:req)       { mock :req, :POST => post_data}
    it "should return a valid image url" do
      service.should_receive(:convert).and_return("SHASIGN")
      (resp_code,headers,content) = subject.do_convert(req)
      resp_code.should == 200
      headers['Content-Type'].should == 'text/plain'
      content[0].should match /^<img src='[^']+'[^>]+>$/
      headers['Content-Length'].should == content[0].size.to_s
    end
  end

  describe "#do_get_png" do
    let(:sha)      { "SHA1" }
    let(:req)      { mock :req, :path => Shutterbug::Rackapp::PNG_PATH + "/" + sha}
    let(:png_file) { mock :png_file, :size => 100 }
    it "should return an image file matching sha in req of type png" do
      service.should_receive(:get_png_file).with(sha).and_return(png_file)
      (resp_code,headers,content) =  subject.do_get_png(req)
      resp_code.should == 200
      headers['Content-Type'].should == 'image/png'
      content.should == png_file
      headers['Content-Length'].should == '100'
    end
  end

  describe "#do_get_html" do
    let(:sha)       { "SHA1" }
    let(:req)       { mock :req, :path => Shutterbug::Rackapp::HTML_PATH + "/" + sha}
    let(:html_file) { mock :html_file, :size => 100 }
    it "should return an image file matching sha in req of type html" do
      service.should_receive(:get_html_file).with(sha).and_return(html_file)
      (resp_code,headers,content) =  subject.do_get_html(req)
      resp_code.should == 200
      headers['Content-Type'].should == 'text/html'
      content.should == html_file
      headers['Content-Length'].should == '100'
    end
  end

  describe "#do_get_shutterbug" do
    let(:sha)       { "SHA1" }
    let(:req)       { mock :req, :path => Shutterbug::Rackapp::JS_PATH }
    let(:js_file  ) { mock :html_file, :size => 100 }
    it "should return an image file matching sha in req of type javascipt" do
      service.should_receive(:get_shutterbug_file).and_return(js_file)
      (resp_code,headers,content) =  subject.do_get_shutterbug(req)
      resp_code.should == 200
      headers['Content-Type'].should == 'application/javascript'
      content.should == js_file
      headers['Content-Length'].should == '100'
    end
  end

  describe "#call" do
    let(:path) { 'bogus'                   }
    let(:req)  { mock(:req, :path => path) }
    let(:sha)  { "542112e" }
    before(:each) do
      Rack::Request.stub!(:new).and_return(req)
    end
      # return do_convert(req)  if req.path =~ CONVERT_REGEX
      # return do_get_png(req)  if req.path =~ GET_PNG_REGEX
      # return do_get_html(req) if req.path =~ GET_HTML_REGEX
      # return do_get_shutterbug(req) if req.path =~ JS_REGEX
    describe "convert route" do
      let(:path) { Shutterbug::Rackapp::CONVERT_PATH  }

      it "should route #do_convert" do
        subject.should_receive(:do_convert, :with => req).and_return true
        subject.call(mock).should be_true
      end
    end

    describe "get png route" do
      let(:path) { "#{Shutterbug::Rackapp::PNG_PATH}/#{sha}" }
      it "should route #do_get_png" do
        subject.should_receive(:do_get_png, :with => req).and_return true
        subject.call(mock).should be_true
      end
    end

    describe "get html route" do
      let(:path) { "#{Shutterbug::Rackapp::HTML_PATH}/#{sha}" }
      it "should route #do_get_html" do
        subject.should_receive(:do_get_html, :with => req).and_return true
        subject.call(mock).should be_true
      end
    end

    describe "get shutterbug javascipt route" do
      let(:path) { "#{Shutterbug::Rackapp::JS_PATH}" }
      it "should route #do_get_shutterbug" do
        subject.should_receive(:do_get_shutterbug, :with => req).and_return true
        subject.call(mock).should be_true
      end
    end

  end

end