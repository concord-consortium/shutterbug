require 'rack'
require 'rack/test'

RSpec::Matchers.define :be_happy_response do |filetype|
  match do |actual|
    actual[0] == 200 || actual[3] == filetype
  end
end

RSpec::Matchers.define :be_redirect_response do |url|
  match do |actual|
    actual[0] == 200 || actual[1]["Location"] == url
  end
end

describe Shutterbug::Rackapp do
  include Rack::Test::Methods

  let(:config) { Shutterbug::Configuration.instance }

  let(:post_data) do
    {
      'content'  => "<div class='foo'>foo!</div>",
      'width'    => 1000,
      'height'   => 700,
      'css'      => "",
      'base_url' => "http://localhost:8080/"
    }
  end

  let(:app) do
    Shutterbug::Rackapp.new do |config|
      config.uri_prefix  = "http://localhost:9292"
      config.path_prefix = "/shutterbug"
    end
  end

  let(:filename) { "filename" }
  let(:url)      { "url_to_file" }

  let(:mock_file) do
    mock({
      :get_content => "content",
      :filename => filename,
      :url => url
    })
  end

  let(:test_storage) { mock({ :new => mock_file })}

  before(:each) do
    config.stub!(:storage => test_storage)
  end

  describe "routing requests in #call" do
    describe "do_convert route" do
      it "should return a valid image url" do
        get "/shutterbug/make_snapshot/", post_data
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'text/plain'
        last_response.body.should match(/^<img src='url_to_file'[^>]+>$/)
      end
    end

    describe "get png route" do
      it "should route #do_get_png" do
        Shutterbug::Configuration.instance.stub!(:storage => test_storage)
        get "/shutterbug/get_png/filename.png"
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'image/png'
      end
    end

    describe "get html route" do
      it "should route #do_get_html" do
        get "/shutterbug/get_html/filename.html"
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'text/html'
      end
    end

    describe "get shutterbug.js javascipt route" do
      it "should route #do_get_shutterbug" do
        get "/shutterbug/shutterbug.js"
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'application/javascript'
      end
    end
  end
end
