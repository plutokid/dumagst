module Dumagst
  module Engines
    class Base
      
      def initialize(opts)
        @opts = opts
      end

      def process
        raise "Implement #process in a subclass!"
      end

      def recommend(opts)
        raise "Implement #recommend in a subclass!"
      end

      def flush

      end

      protected

      def redis
        Dumagst.configuration.redis_connection
      end

    end
  end
end