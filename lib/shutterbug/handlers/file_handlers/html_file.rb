module Shutterbug
  module Handlers
    module FileHandlers
      class HtmlFile < Base

        def self.file_extension
          "html"
        end

        def self.mime_type
          "text/html"
        end

        def handle(helper, req, env)
          sha  = self.class.regex.match(req.path)[1]
          file = self.class.config.storage.new(self.class.filename(sha), self.class)
          helper.response(file.get_content, self.class.mime_type)
        end
      end
    end
  end
end