module Dumagst
  module Engines
    class JaccardEngine < Base
      
      KEY_SEPARATOR = "."
      
      attr_reader :similarity_threshold, :max_similar_users, :max_similar_products

      def initialize(opts)
        super(opts)
        @engine_key = opts.fetch(:engine_key, "jaccard_similarity")
        @matrix = opts.fetch(:matrix, nil)
        @similarity_threshold = opts.fetch(:similarity_threshold, 0.25)
        @max_similar_users = opts.fetch(:max_similar_users, 10)
        @max_similar_products = opts.fetch(:max_similar_products, 20)
      end

      def process
        columns_count = matrix.columns_count
        total_iterations = total_comparisons_count(columns_count)
        log_total_count(columns_count)
        iterations = 0
        for i in 1..columns_count - 1
          for j in i+1..columns_count - 1
            column_i = matrix.column(i)
            column_j = matrix.column(j)
            similarity = matrix.binary? ? binary_similarity_for(column_i, column_j): minhash_similarity_for(column_i, column_j)

            if similarity >= similarity_threshold
              #user is similar enough
              store_similarity_for_user(i, j, similarity)
              store_similarity_for_user(j, i, similarity)
              store_similar_products_for_user(i, column_i, column_j, similarity)
              store_similar_products_for_user(j, column_j, column_i, similarity)
              log_similarity(i, j, similarity)
            end
            iterations += 1
            logger.debug "processed #{iterations} out of #{total_iterations}" if iterations % 10000 == 0
          end
        end
      end

      def recommend_users(user_id, with_scores = true)
        users = redis.zrevrange(key_for_user(user_id), 0, max_similar_users, with_scores: with_scores)
        users.count > 0 ? users.map{| u| SimilarUser.new(u[0].to_i, u[1]) } : []
      end

      def recommend_products(user_id, with_scores = true)
        products = redis.zrevrange(key_for_product(user_id), 0, max_similar_products, with_scores: with_scores)
        products.count > 0 ? products.map{|p| SimilarProduct.new(p[0].to_i, p[1]) } : []
      end

      def users_with_recommended_products
        product_key_pattern = (similar_products_key_array << "*").join(KEY_SEPARATOR)
        keys = redis.keys(product_key_pattern)
        if keys.empty?
          []
        else
          keys.map {|key| key.split(KEY_SEPARATOR)[2].to_i }
        end
      end

      protected

      attr_accessor :matrix, :engine_key

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

      def key_for_user(user_id)
        [
          "#{engine_key}",
          "similar_users",
          "#{user_id}"
        ].join(KEY_SEPARATOR)
      end

      def similar_products_key_array
        [
          "#{engine_key}",
          "similar_products",
        ]
      end

      def key_for_product(user_id)
        (similar_products_key_array << "#{user_id}").join(KEY_SEPARATOR)
      end

      def scaled_score(score)
        (score * score_scale).to_i
      end

      def score_scale
        Dumagst.configuration.score_scale
      end

      private

      include JaccardSimilarity

      def total_comparisons_count(columns_count)
        (columns_count * columns_count) / 2
      end

      def log_total_count(count)
        comparisons = total_comparisons_count(count)
        logger.debug("Jaccard Engine: processing #{count} columns, #{comparisons} comparisons to do")
      end

      def log_similarity(user_id, similar_user_id, score)
        logger.info("Jaccard Engine: User #{user_id} is similar to the user #{similar_user_id}, score: #{score}")
      end

      def log_product_similarity(user_id, product_id, score)
        logger.info("Jaccard Engine: User #{user_id} : similar product #{product_id}, score: #{score}")
      end

    end
  end
end