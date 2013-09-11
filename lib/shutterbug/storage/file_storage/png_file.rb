module Shutterbug
  module Storage
    module FileStorage
      class PngFile  < FileStorage::Base
        def register_handlers
          Shutterbug::Rackapp.add_handler(@config.png_regex) do |helper, req, env|
            helper.good_response(self.get_content, self.mime_type)
          end
        end

        def file_extension
          "png"
        end

        def mime_type
          "image/png"
        end
      end
    end
  end
end