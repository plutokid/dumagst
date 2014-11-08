module Dumagst
  module Engines
    class JaccardEngine < Base

      def initialize(opts)
        super(opts)
        @matrix_key = opts.fetch(:matrix_key, "jaccard_matrix")
      end

      def process
      end

      def recommend
      end

    end
  end
end