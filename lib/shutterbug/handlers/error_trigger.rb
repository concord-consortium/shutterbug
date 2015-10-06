module Shutterbug
  module Handlers
    class ErrorTrigger

      def self.regex
        /#{Configuration.instance.path_prefix}\/error/
      end

      def handle(helper, req, env)
        raise "Forced exception: #{req}, #{env}"
      end
    end

  end
end
