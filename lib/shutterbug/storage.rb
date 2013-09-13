module Shutterbug
  module Storage
    autoload :FileStorage,  "shutterbug/storage/file_storage"
    autoload :S3Storage,    "shutterbug/storage/s3_storage"
  end
end