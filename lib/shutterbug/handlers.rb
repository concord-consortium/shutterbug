require "shutterbug/handlers/file_handlers"
module Shutterbug
  module Handlers
    autoload :ConvertHandler, "shutterbug/handlers/convert_handler"
    autoload :DirectUploadHandler, "shutterbug/handlers/direct_upload_handler"
    autoload :JsFileHandler, "shutterbug/handlers/js_file_handler"
  end
end
