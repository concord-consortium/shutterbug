module Shutterbug
  VERSION = "0.0.12"
  autoload :ConvertHandler, "shutterbug/convert_handler"
  autoload :Rackapp,        "shutterbug/rackapp"
  autoload :Configuration,  "shutterbug/configuration"
  autoload :Storage,        "shutterbug/storage"
  autoload :HtmlFile,       "shutterbug/html_file"
  autoload :PngFile,        "shutterbug/png_file"
  autoload :JsFileHandler,  "shutterbug/js_file_handler"
  autoload :S3File,         "shutterbug/s3_file"
  autoload :PhantomJob,     "shutterbug/phantom_job"
  autoload :CacheManager,   "shutterbug/cache_manager"
end
