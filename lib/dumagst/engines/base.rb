require 'logger'

module Dumagst
  module Engines
    class Base

      KEY_SEPARATOR = "."
      
      attr_reader :similarity_threshold

      def initialize(opts)
        @opts = opts
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
        @logging_enabled = opts.fetch(:logging_enabled, false)
        @similarity_threshold = opts.fetch(:similarity_threshold, 0.25)
      end

      def process
        raise "Implement #process in a subclass!"
      end

      def recommend_users(user_id, with_scores = true)
        raise "Implement #recommend_users in a subclass!"
      end

      def recommend_products(user_id, with_scores = true)
        raise "Implement #recommend_products in a subclass!"
      end

      def users_with_recommended_products
        raise "Implement #users_with_recommended_products in a subclass!"
      end

      def logging_enabled?
        @logging_enabled
      end

      protected

      include EngineKeys

      attr_accessor :matrix, :engine_key

      def redis
        Dumagst.configuration.redis_connection
      end

      def logger
        @logger
      end

      def scaled_score(score)
        (score * score_scale).to_i
      end

      def score_scale
        Dumagst.configuration.score_scale
      end

      def store_similarity_for_user(user_id, similar_user_id, score)
        result = redis.zadd(key_for_user(user_id), scaled_score(score), similar_user_id)
        raise "Cannot set similarity for #{user_id}, similar user : #{similar_user_id}, score : #{score}" unless result
        result
      end

      def store_similar_products_for_user(user_id, user_column, similar_column, score)
        # adjust the ids by one as we start counting from zero
        own_ids = extract_product_ids(user_column)
        product_ids = extract_product_ids(similar_column) - own_ids

        product_ids.map do |product_id|
          redis.zadd(key_for_product(user_id), scaled_score(score), product_id)
          log_product_similarity(user_id, product_id, score)
        end if product_ids.count > 0
      end



    end
  end
end