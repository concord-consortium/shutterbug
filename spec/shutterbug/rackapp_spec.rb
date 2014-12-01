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
      :mime_type => "image/png",
      :filename => filename,
      :url => url
    })
  end

  let(:test_storage) { mock({ :new => mock_file })}

  before(:each) do
    Shutterbug::Configuration.instance.stub!(:storage => test_storage)
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

    describe "get file route" do
      it "should return without errors" do
        get "/shutterbug/get_file/foobar.png"
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'image/png'
      end
    end

    describe "get shutterbug.js javascipt route" do
      it "should return js file" do
        get "/shutterbug/shutterbug.js"
        last_response.should be_ok
        last_response.headers['Content-Type'].should match 'application/javascript'
      end
    end
  end
end
