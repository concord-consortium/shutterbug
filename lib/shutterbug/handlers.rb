module Shutterbug
  module Handlers
    autoload :ConvertHandler, "shutterbug/handlers/convert_handler"
    autoload :DirectUploadHandler, "shutterbug/handlers/direct_upload_handler"
    autoload :FileHandler, "shutterbug/handlers/file_handler"
    autoload :ErrorTrigger, "shutterbug/handlers/error_trigger"
  end
end
