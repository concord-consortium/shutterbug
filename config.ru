
require 'shutterbug'
require 'rack/cors'
use Rack::Cors do
  allow do
    origins '*'
    resource '/shutterbug/*', :headers => :any, :methods => :any
  end
end

use Shutterbug::Rackapp do |config|
  config.uri_prefix   = "http://localhost:9292"
  config.path_prefix  = "/shutterbug"
  config.s3_key       = ENV['S3_KEY']
  config.s3_secret    = ENV['S3_SECRET']
  config.s3_bin       = "ccshutterbugtest"
end

app = Rack::Directory.new "demo"
run app
