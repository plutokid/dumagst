describe Dumagst::Matrices::NativeMatrix do
  let(:csv_file) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "jaccard_10.csv") }
  subject { Dumagst::Matrices::NativeMatrix.from_csv(csv_file, 9, 8) }
  describe ".from_csv" do
    it "returns a matrix given the CSV filename , row and column count, padding the size to accomodate for the zero row and column" do
      expect(subject).to be_a(Dumagst::Matrices::NativeMatrix)
      expect(subject.dimensions).to eq([10, 9])
    end
  end

  describe "#column" do
    it "returns a Vector of elements comprising requested column" do
      expect(subject.column(1)).to eq(Vector[0, 0, 1, 1, 0, 1, 0, 0, 0, 0])
      expect(subject.column(8)).to eq(Vector[0, 1, 0, 0, 0, 0, 1, 0, 0, 0])
    end
    it "raises if you attempt to request a column out of the matrix column range" do
      expect { subject.column(380) }.to raise_error
    end
  end
  
  describe "#row" do
    it "returns a Vector of elements comprising requested row" do
      expect(subject.row(1)).to eq(Vector[0, 0, 0, 0, 1, 1, 0, 0, 1])
      expect(subject.row(8)).to eq(Vector[0, 0, 0, 0, 0, 0, 1, 0, 0])
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

  describe "signature_matrix" do
    include Dumagst::Engines::Similarity
    require 'terminal-table'
    it "returns a NativeMatrix with the required dimensions" do
      sig = subject.signature_matrix(9)
      expect(sig).to be_a(Dumagst::Matrices::NativeMatrix)
      expect(sig.rows_count).to eq(9)
      expect(sig.columns_count).to eq(9)
    end
    it "returns a NativeMatrix with symmetric similarities and 1.0 for diagonal elements" do
      sig = subject.signature_matrix(9)
      sig_sims = []
      sig.each_column_index do |r|
        sig_sims << sig.each_column_index.map do |rr|
          sprintf("%4.3f", minhash_similarity_for(sig.column(r), sig.column(rr)))
        end
      end
      # sig_table = Terminal::Table.new :rows => sig_sims
      # puts sig_table
      (1..8).each do |i|
        (1..8).each do |j|
          if i == j 
            expect(sig_sims[i][i].to_f).to eq(1.0)
          else
            expect(sig_sims[i][j]).to eq(sig_sims[i][j])
          end
        end
      end
    end
  end
end