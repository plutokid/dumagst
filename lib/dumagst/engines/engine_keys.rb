module Dumagst
  module Engines
    module EngineKeys
      KEY_SEPARATOR = "."

      def key_for_user(user_id)
        [
          "#{engine_key}",
          "similar_users",
          "#{user_id}"
        ].join(KEY_SEPARATOR)
      end

      def similar_products_key_array
        [
          "#{engine_key}",
          "similar_products",
        ]
      end

      def key_for_product(user_id)
        (similar_products_key_array << "#{user_id}").join(KEY_SEPARATOR)
      end      

      def extract_product_ids(col, adjust_by = 0)
        col.each_index.select { |i| col[i] == 1}.map {|i| i + adjust_by}
      end

    end
  end
end