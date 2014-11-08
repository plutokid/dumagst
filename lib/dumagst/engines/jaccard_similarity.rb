module Dumagst
  module Engines
    module JaccardSimilarity
      def similarity_for(col_a, col_b)
        union = col_a | col_b
        union.size > 0 ? (col_a & col_b ).size.to_f / union.size : 0
      end

      def binary_similarity_for(col_a, col_b)
        ones_for_a = col_a.each_index.select { |i| col_a[i] == 1}
        ones_for_b = col_b.each_index.select { |i| col_b[i] == 1}
        similarity_for(ones_for_a, ones_for_b)
      end
    end
  end
end