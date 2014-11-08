require 'csv'

module Dumagst
  class Matrix
    attr_accessor :rows_count, :columns_count
    class << self
      def from_csv(filename)
        m = new
        CSV.foreach(filename, col_sep: ",") do |row|
          product_id = row[0]
          user_id = row[1]
          puts "setting : #{product_id} #{user_id}"
          m[product_id, user_id] = 1
        end
        m
      end
    end

    def initialize(rows_count = 0, columns_count = 0)
      @rows_count = rows_count
      @columns_count = columns_count
      @redis = ::Dumagst.configuration.redis_connection
    end

    def [](x, y)
      get_by_key(x,y).to_f
    end

    def []=(x, y, v)
      increment_rows_count_if_needed(x.to_i)
      increment_columns_count_if_needed(y.to_i)
      set_by_key(x, y, v)
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

    attr_accessor :redis

    def key_prefix
      "matrix"
    end

    include RedisKeyMapper
  end
end