module Dumagst
  module Engines
    SimilarUser = Struct.new(:user_id, :score) do
      def to_a
        [user_id, score]
      end

      def score?
        !score.nil
      end
    end
  end
end
