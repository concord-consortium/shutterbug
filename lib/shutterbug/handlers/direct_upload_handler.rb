require 'securerandom'

# This handler can be used for fast, client-side upload of images (or canvas) directly to S3.
# When client is taking snapshot of image or canvas, we don't need to use PhantomJS.
module Shutterbug
  module Handlers
    class DirectUploadHandler
      EXP_TIME = 300 # seconds

      def self.config
        Configuration.instance
      end

      def self.regex
        /#{self.config.path_prefix}\/img_upload_url/
      end

      # Returns put_url and get_url (that will work after file is uploaded).
      def handle(helper, req, env)
        object_path = "img-#{SecureRandom.uuid}.png"
        if self.class.config.use_s3?
          put_url = s3_put_url(object_path)
          # Manual URL construction, no proper method implemented in FOG.
          # But should be available soon, see: https://github.com/fog/fog/issues/3263
          get_url = "https://#{self.class.config.s3_bin}.s3.amazonaws.com/#{object_path}"
        else
          # not implemented yet
          return helper.response('PUT not available for file storage, use S3', 'text/plain', 400)
        end
        helper.response({
          put_url: put_url,
          get_url: get_url
        }.to_json, 'application/json')
      end

      def s3_put_url(object_path)
        expiry = (Time.now + EXP_TIME).to_i
        headers = {}
        query = {
          'x-amz-acl' => 'public-read'
        }
        options = { path_style: true, query: query }
        return Storage::S3Storage.connection.put_object_url(self.class.config.s3_bin, object_path, expiry, headers, options)
      end
    end
  end
end
