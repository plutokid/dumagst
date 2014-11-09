 module Dumagst
  module Matrices
    module RedisMatrixMapper
      CODE_SUCCESS = "OK"
      KEY_SEPARATOR = "."

      def get_by_key(x,y)
        value = redis.get(key_for(x, y))
        value ? value.to_f : value
      end

      def set_by_key(x,y, value)
        value = redis.set(key_for(x, y), value)
        raise "Could not set the key #{key_for(x, y)}" unless value == CODE_SUCCESS
        value
      end

      def key_for(x,y)
        raise KeyError, "invalid value for x : #{x}" if x.to_f < 0 || x.nil?
        raise KeyError, "invalid value for y : #{y}" if y.to_f < 0 || y.nil?
        [
          "#{key_prefix}",
          x.to_s,
          y.to_s
        ].join(KEY_SEPARATOR)
      end

      def reverse_key(key)
        parts = key.split(KEY_SEPARATOR)
        raise "Invalid key given : #{key}. Expected the key to be like 'string.integer_string.integer_string'" unless parts.count == 3
        [parts[1], parts[2]].map(&:to_i)
      end

      def row_pattern(row)
        [
          "#{key_prefix}",
          row.to_s,
          "*"
        ].join(KEY_SEPARATOR)
      end

      def column_pattern(column)
        [
          "#{key_prefix}",
          "*",
          column.to_s,
        ].join(KEY_SEPARATOR)
      end
    end
  end
end