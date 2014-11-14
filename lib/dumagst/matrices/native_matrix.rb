require 'matrix'
module Dumagst
  module Matrices
    class NativeMatrix < Base

      class MutableMatrix < ::Matrix
        public :"[]=", :set_element, :set_component
      end

      class << self
        def from_csv(filename, rows_count, columns_count)
          # add padding and discard the row 0 and column 0
          m = new(rows_count: rows_count + 1, columns_count: columns_count + 1)
          CSV.foreach(filename, col_sep: ",") do |row|
            product_id = row[0]
            user_id = row[1]
            m[product_id, user_id] = Base::VALUE_SET
          end
          m
        end
      end

      def initialize(opts)
        rows_count = opts.fetch(:rows_count)
        columns_count = opts.fetch(:columns_count)
        fill_with_value = opts.fetch(:fill_with, 0)
        @matrix = MutableMatrix.build(rows_count, columns_count) {|row, col| fill_with_value }
      end

      def rows_count
        matrix.row_count
      end

      def each_row_index
        (0..rows_count-1).each { |c| yield c }
      end

      def columns_count
        matrix.column_count
      end

      def [](x, y)
        matrix[x.to_i, y.to_i]
      end

      def []=(x, y, v)
        matrix[x.to_i, y.to_i] = v
      end

      def column(y)
        raise "column #{y} is outside of the matrix column range [0..#{columns_count-1}]" unless y < columns_count
        matrix.column(y).to_a
      end

      def row(x)
        raise "row #{x} is outside of the matrix row range [0..#{rows_count-1}]" unless x < rows_count
        matrix.row(x).to_a
      end

      def dimensions
        [rows_count, columns_count]
      end

      def to_signature_matrix(buckets)
        raise "can't have more buckets than rows" if buckets > rows_count
        sig = NativeMatrix.new(rows_count: buckets, columns_count: columns_count, fill_with: Float::INFINITY)
        minhash_functions = Array.new(buckets, MinhashFunction.generate(buckets))
        hr = minhash_functions.each.map do |func|
          (0..rows_count).map {|row_count| puts row_count; func.hash_for(row_count) }
        end
        require 'pry' ; binding.pry
        for i in 1..rows_count
          (0..minhash_functions.size).each do |hsh_index|
            dupa = hsh_index
            
            hr << (0..rows_count).map {|row_count| minhash_functions[dupa].hash_for(row_count) }
          end
          puts "ulala"
        end
      end

      private

      attr_accessor :matrix

    end
  end
end