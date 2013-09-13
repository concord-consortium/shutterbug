module Shutterbug
  module Handlers
    module FileHandlers
      class PngFile < Base

        def file_extension
          "png"
        end

        def mime_type
          "image/png"
        end

        def handle(helper, req, env)
          local_filename  = regex.match(req.path)[1]
          file = @config.storage.new(local_filename,self)
          helper.good_response(file.get_content, self.mime_type)
        end
      end
    end
  end

end