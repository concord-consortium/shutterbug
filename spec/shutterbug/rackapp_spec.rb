require 'rack'
RSpec::Matchers.define :be_happy_response do |filetype|
  match do |actual|
    actual[0] == 200 || actual[3] == filetype
  end
end

describe Shutterbug::Rackapp do
  let(:sha)     { "542112e"                     }
  let(:size)    { 200                           }
  let(:rackfile){ mock :fackfile, :size => size }
  let(:service) { mock :service                 }
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
      service.should_receive(:convert).and_return(sha)
      (resp_code,headers,content) = subject.do_convert(req)
      resp_code.should == 200
      headers['Content-Type'].should == 'text/plain'
      content[0].should match /^<img src='[^']+'[^>]+>$/
      headers['Content-Length'].should == content[0].size.to_s
    end
  end

  describe "rounting requests in #call" do
    let(:path) { 'bogus'                   }
    let(:req)  { mock(:req, :path => path) }
    before(:each) do
      Rack::Request.stub!(:new).and_return(req)
    end

    describe "convert route" do
      let(:path)           { subject.config.convert_path }
      let(:image_response) { mock :image_response               }
      it "should route #do_convert" do
        subject.should_receive(:do_convert, :with => req).and_return image_response
        subject.call(mock).should == image_response
      end
    end

    describe "get png route" do
      let(:path) { subject.config.png_path(sha) }
      it "should route #do_get_png" do
        service.should_receive(:get_png_file, :with => sha).and_return rackfile
        subject.call(mock).should be_happy_response('image/png')
      end
    end

    describe "get html route" do
      let(:path) { subject.config.html_path(sha) }
      it "should route #do_get_html" do
        service.should_receive(:get_html_file, :with => sha).and_return rackfile
        subject.call(mock).should be_happy_response('text/html')
      end
    end

    describe "get shutterbug javascipt route" do
      let(:path) {subject.config.js_path }
      it "should route #do_get_shutterbug" do
        service.should_receive(:get_shutterbug_file).and_return rackfile
        subject.call(mock).should be_happy_response('application/javascript')
      end
    end

  end

end