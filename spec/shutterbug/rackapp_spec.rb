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

  describe "#do_get_html"
  describe "#do_get_shutterbug"
  describe "#hand_off"
  describe "#call"

end