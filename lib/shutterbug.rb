module Shutterbug
  VERSION = "0.2.4"
  autoload :Rackapp,        "shutterbug/rackapp"
  autoload :Configuration,  "shutterbug/configuration"
  autoload :Storage,        "shutterbug/storage"
  autoload :Handlers,       "shutterbug/handlers"
  autoload :PhantomJob,     "shutterbug/phantom_job"
  autoload :CacheManager,   "shutterbug/cache_manager"
end
