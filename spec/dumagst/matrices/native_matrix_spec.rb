describe Dumagst::Matrices::NativeMatrix do
  let(:csv_file) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "jaccard_10.csv") }
  subject { Dumagst::Matrices::NativeMatrix.from_csv(csv_file, 9, 8) }
  describe ".from_csv" do
    it "returns a matrix given the CSV filename , row and column count" do
      expect(subject).to be_a(Dumagst::Matrices::NativeMatrix)
      expect(subject.dimensions).to eq([10, 9])
    end
  end

  describe "#column" do
    it "returns an array of elements comprising requested column" do
      expect(subject.column(1)).to eq([0, 0, 1, 1, 0, 1, 0, 0, 0, 0])
      expect(subject.column(8)).to eq([0, 1, 0, 0, 0, 0, 1, 0, 0, 0])
    end
    it "raises if you attempt to request a column out of the matrix column range" do
      expect { subject.column(380) }.to raise_error
    end
    it "returns an empty array if "
  end
  
  describe "#row" do
    it "returns an array of elements comprising requested row" do
      expect(subject.row(1)).to eq([0, 0, 0, 0, 1, 1, 0, 0, 1])
      expect(subject.row(8)).to eq([0, 0, 0, 0, 0, 0, 1, 0, 0])
    end
    it "raises if you attempt to request a row out of the matrix row range" do
      expect { subject.row(380) }.to raise_error
    end
  end

  describe "#each_row_index" do
    it "provides an enumerator over the row indices" do
      expect(subject.each_row_index).to be_a(Enumerator)
    end
    it "yields the row indices in succession if a block is given" do
      expect { |b| subject.each_row_index(&b) }.to yield_successive_args(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    end
  end

  describe "#each_column_index" do
    it "provides an enumerator over the column indices" do
      expect(subject.each_column_index).to be_a(Enumerator)
    end
    it "yields the column indices in succession if a block is given" do
      expect { |b| subject.each_column_index(&b) }.to yield_successive_args(0, 1, 2, 3, 4, 5, 6, 7, 8)
    end
  end

  describe "#binary?" do
    it "returns true for a matrix created with .from_csv" do
      expect(subject).to be_binary
    end
    it "returns false if explicitly created with binary:false" do
      matrix = Dumagst::Matrices::NativeMatrix.new(rows_count: 2, columns_count: 4, binary: false)
      expect(matrix).to_not be_binary
    end
  end

  describe "to_signature_matrix" do
    include Dumagst::Engines::JaccardSimilarity
    require 'terminal-table'
    it "returns a NativeMatrix with the required dimensions" do
      sig = subject.to_signature_matrix(9)
      #puts sig.inspect
      real_sims = []
      subject.each_column_index do |r|
        real_sims << subject.each_column_index.map do |rr|
          nil if r == rr
          sprintf("%4.3f", binary_similarity_for(subject.column(r), subject.column(rr)))
        end
      end
      sig_sims = []
      sig.each_column_index do |r|
        sig_sims << sig.each_column_index.map do |rr|
          nil if r == rr
          sprintf("%4.3f", similarity_for(sig.column(r), sig.column(rr)))
        end
      end
      real_table = Terminal::Table.new :rows => real_sims
      puts real_table
      sig_table = Terminal::Table.new :rows => sig_sims
      puts sig_table
      #require 'pry'; binding.pry
      expect(sig).to be_a(Dumagst::Matrices::NativeMatrix)
      expect(sig.rows_count).to eq(9)
      expect(sig.columns_count).to eq(9)
    end
  end


end