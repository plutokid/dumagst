module Dumagst
  module Engines
    class JaccardEngine < Base
      attr_reader :similarity_threshold, :max_similar_users

      def initialize(opts)
        super(opts)
        @engine_key = opts.fetch(:engine_key, "jaccard_similarity")
        @matrix = Dumagst::Matrices::RedisMatrix.from_csv(@filename)
        @similarity_threshold = opts.fetch(:similarity_threshold, 0.25)
        @max_similar_users = opts.fetch(:max_similar_users, 10)
      end

      def process
        columns_count = matrix.columns_count
        for i in 1..columns_count
          for j in i+1..columns_count
            similarity = binary_similarity_for(matrix.column(i), matrix.column(j))
            if similarity >= similarity_threshold
              #user is similar enough
              store_similarity_for_user(i, j, similarity)
              store_similarity_for_user(j, i, similarity)
            end
            puts "similarity for column #{i} and column #{j} is #{similarity}" if similarity > 0
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
        redis.zadd(key_for_user(user_id), (score * 1000).to_i, similar_user_id)
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

    end
  end
end