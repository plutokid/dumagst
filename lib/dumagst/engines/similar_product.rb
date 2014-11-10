module Dumagst
  module Engines
    SimilarProduct = Struct.new(:product_id, :score) do
      def to_a
        [product_id, score]
      end

      def score?
        !score.nil
      end
    end
  end
end
