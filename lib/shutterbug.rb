module Shutterbug
  VERSION = "0.0.11"
  autoload :Service,        "shutterbug/service"
  autoload :Rackapp,        "shutterbug/rackapp"
  autoload :Configuration,  "shutterbug/configuration"
  autoload :BugFile,        "shutterbug/bug_file"
  autoload :HtmlFile,       "shutterbug/html_file"
  autoload :PngFile,        "shutterbug/png_file"
  autoload :JsFile,         "shutterbug/js_file"
  autoload :PhantomJob,     "shutterbug/phantom_job"
end
