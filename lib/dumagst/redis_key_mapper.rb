module Dumagst
  module RedisKeyMapper
    def get_by_key(x,y)
      value = redis.get(key_for(x, y))
      value ? value.to_f : value
    end

    def set_by_key(x,y, value)
      redis.set(key_for(x, y), value)
    end

    def key_for(x,y)
      raise KeyError, "invalid value for x : #{x}" if x.to_f < 0 || x.nil?
      raise KeyError, "invalid value for y : #{y}" if y.to_f < 0 || y.nil?
      [
        "#{key_prefix}",
        x,
        y
      ].join(".")
    end
  end
end