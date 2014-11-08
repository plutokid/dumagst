
require 'redis'

module DuMagst
  class Matrix
    attr_accessor :rows, :columns, :dimensions

    def initialize(dimensions)
      @dimensions = dimensions
      @redis = ::DuMagst.configuration.redis_connection
    end

    def rows_count
      @dimensions[0]
    end

    def columns_count
      @dimensions[1]
    end

    def [](x,y)
      get_by_key(x,y).to_f
    end

    def []=(x,y)
      set_by_key(x,y)
    end

    private

    attr_accessor :redis

    def key_prefix
      "matrix"
    end

    include Dumagst::RedisKeyMapper
  end
end