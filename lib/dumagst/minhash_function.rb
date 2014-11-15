require 'securerandom'
module Dumagst
  module Matrices
    class MinhashFunction
      
      attr_reader :a, :b, :buckets
      RAND_MAX = 2**32 - 1
      class << self
        def generate(buckets)
          new(
            SecureRandom.random_number(RAND_MAX),
            SecureRandom.random_number(RAND_MAX),
            buckets
          )
        end
      end 
      
      def initialize(a, b, buckets)
        @a = a
        @b = b
        @buckets = buckets
      end

      def hash_for(value)
        (a * value + b) % buckets
      end

    end
  end
end