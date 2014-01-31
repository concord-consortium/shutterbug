module Shutterbug
  VERSION = "0.1.3"
  autoload :Rackapp,        "shutterbug/rackapp"
  autoload :Configuration,  "shutterbug/configuration"
  autoload :Storage,        "shutterbug/storage"
  autoload :Handlers,       "shutterbug/handlers"
  autoload :PhantomJob,     "shutterbug/phantom_job"
  autoload :CacheManager,   "shutterbug/cache_manager"
end
