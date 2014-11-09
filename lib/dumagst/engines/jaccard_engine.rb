module Dumagst
  module Engines
    class JaccardEngine < Base
      attr_reader :similarity_threshold, :max_similar_users

      def initialize(opts)
        super(opts)
        @engine_key = opts.fetch(:engine_key, "jaccard_similarity")
        @matrix = opts.fetch(:matrix, nil)
        @similarity_threshold = opts.fetch(:similarity_threshold, 0.25)
        @max_similar_users = opts.fetch(:max_similar_users, 10)
      end

      def process
        columns_count = matrix.columns_count
        log_total_count(columns_count)
        for i in 1..columns_count
          for j in i+1..columns_count
            similarity = binary_similarity_for(matrix.column(i), matrix.column(j))
            if similarity >= similarity_threshold
              #user is similar enough
              store_similarity_for_user(i, j, similarity)
              store_similarity_for_user(j, i, similarity)
              log_similarity(i, j, similarity)
            end
          end
        end
      end

      def recommend_users(user_id)
        users = redis.zrevrange(key_for_user(user_id), 0, max_similar_users)
        users.count > 0 ? users.map(&:to_i) : []
      end

      def recommend_products(user_id)
        
      end

      protected

      attr_accessor :matrix, :engine_key

      def store_similarity_for_user(user_id, similar_user_id, score)
        result = redis.zadd(key_for_user(user_id), (score * 1000.0).to_i, similar_user_id)
        raise "Cannot set similarity for #{user_id}, similar user : #{similar_user_id}, score : #{score}" unless result
        result
      end

      def key_for_user(user_id)
        [
          "#{engine_key}",
          "similarity_for",
          "#{user_id}"
        ].join(".")
      end

      private

      include JaccardSimilarity

      def log_total_count(count)
        comparisons = (count * count) / 2
        logger.debug("Jaccard Engine: processing #{count} columns, #{comparisons} comparisons to do")
      end

      def log_similarity(user_id, similar_user_id, score)
        logger.info("Jaccard Engine: User #{user_id} is similar to the user #{similar_user_id}, score: #{score}")
      end

    end
  end
end