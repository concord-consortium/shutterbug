module Shutterbug
  module Storage
    module FileStorage
      class HtmlFile < FileStorage::Base
        def register_handlers
          Shutterbug::Rackapp.add_handler(@config.html_regex) do |helper, req, env|
            helper.good_response(self.get_content, self.mime_type)
          end
        end

        def file_extension
          "html"
        end

        def mime_type
          "text/html"
        end
      end
    end
  end
end