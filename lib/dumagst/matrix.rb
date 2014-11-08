require 'csv'

module Dumagst
  class Matrix
    #this feels a bit dumb
    VALUE_SET = 1
    VALUE_UNSET = 0

    attr_accessor :rows_count, :columns_count
    class << self
      def from_csv(filename, matrix_key = "matrix")
        m = new(matrix_key)
        CSV.foreach(filename, col_sep: ",") do |row|
          product_id = row[0]
          user_id = row[1]
          m[product_id, user_id] = VALUE_SET
        end
        m
      end
    end

    def initialize(matrix_key = "matrix", rows_count = 0, columns_count = 0)
      @rows_count = rows_count
      @columns_count = columns_count
      @matrix_key = matrix_key
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
      column = Array.new(@rows_count, VALUE_UNSET)
      redis.keys(column_pattern(y)).each do |key|
        parts = reverse_key(key)
        column[parts[0]] = VALUE_SET
      end
      column
    end

    def dimensions
      [@rows_count, @columns_count]
    end

    protected

    def row_in_bounds?(row)
      row < @rows_count
    end

    def column_in_bounds?(column)
      column < @columns_count
    end

    def increment_rows_count_if_needed(value)
      @rows_count = value if value > @rows_count
    end

    def increment_columns_count_if_needed(value)
      @columns_count = value if value > @columns_count
    end

    private

    attr_accessor :redis

    def key_prefix
      @matrix_key
    end

    include RedisMatrixMapper
  end
end