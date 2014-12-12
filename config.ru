
require 'shutterbug'
require 'rack/cors'
use Rack::Cors do
  allow do
    origins '*'
     resource '*', :headers => :any, :methods => [:get, :post, :options]
  end
end

use Shutterbug::Rackapp do |config|
  config.uri_prefix   = "http://localhost:9292"
  config.path_prefix  = "/shutterbug"
  config.s3_key       = ENV['S3_KEY']
  config.s3_secret    = ENV['S3_SECRET']
  config.s3_bin       = "ccshutterbugtest"
  # config.skip_direct_upload = true  
end

app = Rack::Directory.new "demo"
run app
