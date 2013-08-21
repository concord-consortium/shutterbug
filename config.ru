
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
# config.s3_key       = "your_S3_KEY"
# config.s3_secret    = "your_S3_SECRET_DONT_COMMIT_IT"
# config.s3_bin       = "your_S3_bucket_name"
end

app = Rack::Directory.new "demo"
run app
