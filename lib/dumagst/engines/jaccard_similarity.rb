module Dumagst
  module Engines
    module JaccardSimilarity
      def similarity_for(col_a, col_b)
        #raise "Argument sizes must match. Got #{col_a.size} and #{col_b.size} " unless col_a.size == col_b.size
        union = col_a | col_b
        union.size > 0 ? (col_a & col_b ).size.to_f / union.size : 0
      end
    end
  end
end