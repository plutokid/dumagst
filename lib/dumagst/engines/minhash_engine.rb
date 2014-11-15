module Dumagst
  module Engines
    class MinhashEngine < JaccardEngine

      def initialize(opts)
        super(opts)
        @engine_key = opts.fetch(:engine_key, "minhash_similarity")
      end

      def process
        signature_matrix = matrix.signature_matrix

        columns_count = signature_matrix.columns_count
        total_iterations = total_comparisons_count(columns_count)
        log_total_count(columns_count)
        iterations = 0
        signature_matrix.each_column.drop(1).each do |i|
          signature_matrix.each_column.drop(i+1).each do |j|
            column_i = signature_matrix.column(i)
            column_j = signature_matrix.column(j)
            similarity = minhash_similarity_for(column_i, column_j)
            store_similar_user_and_products(i, j, similarity) if similarity >= similarity_threshold
            iterations += 1
            logger.debug "processed #{iterations} out of #{total_iterations}" if iterations % 10000 == 0
          end
        end
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