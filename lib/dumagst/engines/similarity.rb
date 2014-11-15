module Dumagst
  module Engines
    module Similarity
      def similarity_for(col_a, col_b)
        union = col_a | col_b
        union.size > 0 ? (col_a & col_b ).size.to_f / union.size : 0
      end

      def minhash_similarity_for(col_a, col_b)
        intersection_count = col_a.each_index.select { |i| col_a[i] == col_b[i] }.size
        intersection_count.to_f / col_a.size
      end

      def binary_similarity_for(col_a, col_b)
        raise "arguments must have the same size. Got #{col_a.size} and #{col_b.size}" unless col_a.size == col_b.size
        m11 = col_a.each_index.select {|i| col_a[i] == 1 && col_a[i] == col_b[i] }.size
        m01 = col_a.each_index.select {|i| col_a[i] == 1 && col_b[i] == 0 }.size
        m10 = col_a.each_index.select {|i| col_a[i] == 0 && col_b[i] == 1 }.size
        m11 == 0 ? 0 : (0.0 + m11) / (m01 + m10 + m11)
      end

    end
  end
end