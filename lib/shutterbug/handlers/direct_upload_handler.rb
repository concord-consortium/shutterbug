require 'securerandom'

# This handler can be used for fast, client-side upload of images (or canvas) directly to S3.
# When client is taking snapshot of image or canvas, we don't need to use PhantomJS.
module Shutterbug
  module Handlers
    class DirectUploadHandler

      def self.config
        Configuration.instance
      end

      def self.regex
        /#{self.config.path_prefix}\/img_upload_url/
      end

      # Returns put_url and get_url for a new file that should be uploaded by the client.
      # Of course get_url will work after file is uploaded.
      def handle(helper, req, env)
        object_name = "img-#{SecureRandom.uuid}.png"
        storage = self.class.config.storage
        unless storage.respond_to? :put_url
          return helper.response('direct upload not available', 'text/plain', 400)
        end
        unless storage.respond_to? :get_url
          return helper.response('direct upload not available', 'text/plain', 400)
        end
        helper.response({
          put_url: storage.put_url(object_name),
          get_url: storage.get_url(object_name),
        }.to_json, 'application/json')
      end

      def s3_put_url(object_path)

      end
    end
  end
end
