module Dumagst
  module Engines
    class MinhashEngine < JaccardEngine

      attr_reader :buckets

      def initialize(opts)
        defaults = {engine_key: "minhash_similarity", similarity_threshold: 0.75}
        super(defaults.merge(opts))
        @buckets = opts.fetch(:buckets)
      end

      def process
        signature_matrix = matrix.signature_matrix(buckets)

        columns_count = signature_matrix.columns_count
        total_iterations = total_comparisons_count(columns_count)
        log_total_count(columns_count)
        iterations = 0
        signature_matrix.each_column_index.drop(1).each do |i|
          signature_matrix.each_column_index.drop(i+1).each do |j|
            column_i = signature_matrix.column(i)
            column_j = signature_matrix.column(j)
            similarity = calculate_similarity(column_i, column_j)
            store_similar_user_and_products(i, j, similarity) if similarity >= similarity_threshold
            iterations += 1
            logger.debug "processed #{iterations} out of #{total_iterations}" if iterations % 10000 == 0
          end
        end
      end

      def calculate_similarity(col_a, col_b)
        minhash_similarity_for(col_a, col_b)
      end

      protected

      def store_similar_user_and_products(user_index, similar_user_index, similarity)
        store_similarity_for_user(user_index, similar_user_index, similarity)
        store_similarity_for_user(similar_user_index, user_index, similarity)
        # get the products from the original matrix
        user_products = matrix.column(user_index)
        similar_user_products = matrix.column(similar_user_index)
        store_similar_products_for_user(user_index, user_products, similar_user_products, similarity)
        store_similar_products_for_user(similar_user_index, similar_user_products, user_products, similarity)
      end

    end
  end
end