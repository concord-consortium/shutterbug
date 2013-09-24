require 'tmpdir'
module Shutterbug
  module Handlers
    module FileHandlers
      class Base
        attr_accessor :config

        def self.instance
          return @instance || self.new
        end

        def initialize(_config = Configuration.instance)
          self.config = _config
        end

        def urlify(name)
          "#{self.config.uri_prefix}#{self.path_prefix}/#{name}"
        end

        def path_prefix
          "#{self.config.path_prefix}/get_#{file_extension}"
        end

        def filename_matcher
          "(([^\/|\.]+)\.?([^\/]+))?"
        end

        def regex
          /#{path_prefix}\/#{filename_matcher}/
        end

        def filename(base)
          "#{base}.#{file_extension}"
        end

      end
    end
  end
end