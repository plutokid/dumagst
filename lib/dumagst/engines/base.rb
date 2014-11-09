require 'logger'

module Dumagst
  module Engines
    class Base
      
      def initialize(opts)
        @opts = opts
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
        @logging_enabled = opts.fetch(:logging_enabled, false)
      end

      def process
        raise "Implement #process in a subclass!"
      end

      def recommend(opts)
        raise "Implement #recommend in a subclass!"
      end

      def flush

      end

      def logging_enabled?
        @logging_enabled
      end

      protected

      def redis
        Dumagst.configuration.redis_connection
      end

      def logger
        @logger
      end

    end
  end
end