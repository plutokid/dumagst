module Dumagst
  module Engines
    class JaccardEngine < Base

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
        matrix.each_column_index.drop(1).each do |i|
          matrix.each_column_index.drop(i+1).each do |j|
            column_i = matrix.column(i)
            column_j = matrix.column(j)
            similarity = calculate_similarity(column_i, column_j)
            store_similar_user_and_products(i, j, similarity) if similarity >= similarity_threshold
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

      attr_accessor :matrix

      def calculate_similarity(col_a, col_b)
        binary_similarity_for(col_a, col_b)
      end

      include Similarity

      def store_similar_user_and_products(user_index, similar_user_index, similarity)
        store_similarity_for_user(user_index, similar_user_index, similarity)
        store_similarity_for_user(similar_user_index, user_index, similarity)
        # get the products from the original matrix
        user_products = matrix.column(user_index)
        similar_user_products = matrix.column(similar_user_index)
        store_similar_products_for_user(user_index, user_products, similar_user_products, similarity)
        store_similar_products_for_user(similar_user_index, similar_user_products, user_products, similarity)
      end


      private


      def total_comparisons_count(columns_count)
        (columns_count * columns_count) / 2
      end

      def log_total_count(count)
        comparisons = total_comparisons_count(count)
        logger.debug("#{self.class}: processing #{count} columns, #{comparisons} comparisons to do")
      end

      def log_similarity(user_id, similar_user_id, score)
        logger.info("#{self.class}: User #{user_id} is similar to the user #{similar_user_id}, score: #{score}")
      end

      def log_product_similarity(user_id, product_id, score)
        logger.info("#{self.class}: User #{user_id} : similar product #{product_id}, score: #{score}")
      end

    end
  end
end