require 'tmpdir'

module Shutterbug
  module Handlers
    module FileHandlers
      class Base
        attr_accessor :config

        def self.config
          Configuration.instance
        end

        def self.path_prefix
          "#{self.config.path_prefix}/get_#{self.file_extension}"
        end

        def self.urlify(name)
          "#{self.config.uri_prefix}#{self.path_prefix}/#{name}"
        end

        def self.filename_matcher
          "(([^\/|\.]+)\.?([^\/]+))?"
        end

        def self.filename(base)
          "#{base}.#{self.file_extension}"
        end

        def self.regex
          /#{self.path_prefix}\/#{self.filename_matcher}/
        end
      end
    end
  end
end
