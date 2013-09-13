module Shutterbug
  module Handlers
    module FileHandlers
      class HtmlFile < Base

        def file_extension
          "html"
        end

        def mime_type
          "text/html"
        end

        def handle(helper, req, env)
          sha  = regex.match(req.path)[1]
          file = @config.storage.new(filename(sha),self)
          helper.good_response(file.get_content, self.mime_type)
        end
      end
    end
  end
end