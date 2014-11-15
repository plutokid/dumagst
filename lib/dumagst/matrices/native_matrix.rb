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
          m = new(rows_count: rows_count + 1, columns_count: columns_count + 1, binary: true)
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
        @binary = opts.fetch(:binary, false)
        @matrix = MutableMatrix.build(rows_count, columns_count) {|row, col| fill_with_value }
      end

      def rows_count
        matrix.row_count
      end

      def binary?
        @binary
      end

      def each_row_index
        if block_given?
          (0..rows_count-1).each { |c| yield c }
        else
          (0..rows_count-1).each
        end
      end

      def each_column_index
        if block_given?
          (0..columns_count-1).each { |c| yield c }
        else
          (0..columns_count-1).each
        end
      end

      def each_row
        each_row_index { |i| yield row(i)}
      end

      def each_column
        each_column_index { |i| yield column(i)}
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
        matrix.column(y)
      end

      def row(x)
        raise "row #{x} is outside of the matrix row range [0..#{rows_count-1}]" unless x < rows_count
        matrix.row(x)
      end

      def dimensions
        [rows_count, columns_count]
      end

      def signature_matrix(buckets)
        raise "can't have more buckets than rows" if buckets > rows_count
        sig = NativeMatrix.new(rows_count: buckets, columns_count: columns_count, fill_with: Float::INFINITY, binary: false)
        minhash_functions = Array.new(buckets) {|b| MinhashFunction.generate(buckets) }
        each_row_index do |r|
          hash_values = minhash_functions.map {|func| func.hash_for(r)}
          each_column_index do |c|
            hash_values.each_index {|i| sig[i, c] = (sig[i, c] < hash_values[i] ? sig[i, c] : hash_values[i]) } if self[r, c] != 0
          end
        end
        sig
      end

      private

      attr_accessor :matrix

    end
  end
end