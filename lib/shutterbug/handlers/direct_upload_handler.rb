require 'securerandom'

# This handler can be used for fast, client-side upload of images (or canvas) directly to S3.
# When client is taking snapshot of image or canvas, we don't need to use PhantomJS.

module Shutterbug
  module Handlers
    class DirectUploadHandler
      EXP_TIME = 300 # seconds

      def initialize(_config = Configuration.instance)
        @config = _config
      end

      def regex
        /#{@config.path_prefix}\/img_upload_url/
      end

      # Returns upload_url and image_url (that will obviously work after upload is finished)
      # Note that direct upload is supported only for S3.
      # When S3 is not used, 400 is returned.
      def handle(helper, req, env)
        unless @config.use_s3?
          return helper.response('S3 is not available', 'text/plain', 400)
        end

        object_path = "img-#{SecureRandom.uuid}.png"
        helper.response({
          upload_url: put_url(object_path),
          # Manual URL construction, no proper method implemented in FOG.
          # But should be available soon, see: https://github.com/fog/fog/issues/3263
          image_url: "https://#{@config.s3_bin}.s3.amazonaws.com/#{object_path}"
        }.to_json, 'application/json')
      end

      def put_url(object_path)
        expiry = (Time.now + EXP_TIME).to_i
        headers = {}
        query = {
          'x-amz-acl' => 'public-read'
        }
        options = { path_style: true, query: query }
        return Storage::S3Storage.connection.put_object_url(@config.s3_bin, object_path, expiry, headers, options)
      end
    end
  end
end
