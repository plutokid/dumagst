module Dumagst
  module Matrices
    class Base
      VALUE_SET = 1
      VALUE_UNSET = 0

      attr_accessor :rows_count, :columns_count

      def initialize(opts)
        @opts = opts
        @rows_count = opts.fetch(:rows_count, 0)
        @columns_count = opts.fetch(:columns_count, 0)
      end

      def [](x, y)
        raise "implement [](x, y) in your subclass"
      end

      def []=(x, y, v)
        raise "implement [](x, y, v) in your subclass"
      end

      def column(y)
        raise "implement column(y) in your subclass"
      end

      def row(y)
        raise "implemenet row(y) in your subclass"
      end

      def dimensions
        [@rows_count, @columns_count]
      end

      protected

      def row_in_bounds?(row)
        row < rows_count
      end

      def column_in_bounds?(column)
        column <= columns_count
      end      

    end
  end
end