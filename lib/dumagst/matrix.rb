module Dumagst
  class Matrix
    attr_accessor :rows, :columns, :dimensions

    def initialize(dimension_x, dimension_y)
      @dimensions = [dimension_x, dimension_y]
      @redis = ::Dumagst.configuration.redis_connection
    end

    def rows_count
      @dimensions[0]
    end

    def columns_count
      @dimensions[1]
    end

    def [](x, y)
      get_by_key(x,y).to_f
    end

    def []=(x, y, v)
      set_by_key(x, y, v)
    end

    private

    attr_accessor :redis

    def key_prefix
      "matrix"
    end

    include RedisKeyMapper
  end
end