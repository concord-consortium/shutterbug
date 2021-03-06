require 'securerandom'

# This handler can be used for fast, client-side upload of images (or canvas) directly to storage.
# When client is taking snapshot of image or canvas, we don't need to use PhantomJS.
module Shutterbug
  module Handlers
    class DirectUploadHandler

      def skip_direct_upload
        return true if Configuration.instance.skip_direct_upload
        return true unless Configuration.instance.use_s3?
        return false
      end

      def self.regex
        /#{Configuration.instance.path_prefix}\/img_upload_url/
      end

      # Returns put_url and get_url for a new file that should be uploaded by the client.
      # Of course get_url will work after file is uploaded.
      def handle(helper, req, env)
        if skip_direct_upload
          not_available_response(helper)
        else
          format = req.GET()['format'] || 'png'
          object_name = "img-#{SecureRandom.uuid}.#{format}"
          storage = Configuration.instance.storage
          unless storage.respond_to? :put_url
            not_available_response(helper)
          end
          helper.response({
            put_url: storage.put_url(object_name),
            get_url: storage.get_url(object_name),
          }.to_json, 'application/json')
        end
      end

      def not_available_response(helper)
        return helper.response('direct upload not available', 'text/plain', 400)
      end
    end
  end
end
