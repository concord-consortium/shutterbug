module Shutterbug
  module Handlers
    module FileHandlers
      class PngFile < Base

        def self.file_extension
          "png"
        end

        def self.mime_type
          "image/png"
        end

        def handle(helper, req, env)
          local_filename = self.class.regex.match(req.path)[1]
          file = self.class.config.storage.new(local_filename, self.class)
          helper.response(file.get_content, self.class.mime_type)
        end
      end
    end
  end
end
