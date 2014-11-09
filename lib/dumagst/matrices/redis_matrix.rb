require 'csv'

module Dumagst
  module Matrices
    class RedisMatrix < Base

      attr_accessor :rows_count, :columns_count

      def initialize(opts)
        super(opts)
        @matrix_key = opts.fetch(:matrix_key)
        @redis = ::Dumagst.configuration.redis_connection
      end

      def [](x, y)
        # raise "Row out of bound : trying to access row #{x} while the matrix only has #{rows_count-1} rows" unless row_in_bounds?(x)
        # raise "Column out of bound : trying to access column #{y} while the matrix only has #{columns_count-1} columns" unless column_in_bounds?(y)
        get_by_key(x,y).to_f
      end

      def []=(x, y, v)
        increment_rows_count_if_needed(x.to_i)
        increment_columns_count_if_needed(y.to_i)
        set_by_key(x, y, v)
      end

      def column(y)
        return [] unless column_in_bounds?(y)
        column = Array.new(@rows_count, Base::VALUE_UNSET)
        redis.keys(column_pattern(y)).each do |key|
          parts = reverse_key(key)
          column[parts[0] - 1] = Base::VALUE_SET
        end
        column
      end

      def dimensions
        [@rows_count, @columns_count]
      end

      protected

      def increment_rows_count_if_needed(value)
        @rows_count = value if value > @rows_count
      end

      def increment_columns_count_if_needed(value)
        @columns_count = value if value > @columns_count
      end

      private

      attr_accessor :redis, :matrix_key

      def key_prefix
        matrix_key
      end

      include RedisMatrixMapper
    end
  end
end