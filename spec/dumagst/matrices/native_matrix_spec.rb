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
      expect(subject.column(1)).to eq([0, 1, 1, 0, 1, 0, 0, 0, 0])
      expect(subject.column(8)).to eq([1, 0, 0, 0, 0, 1, 0, 0, 0])
    end
    it "returns an empty array if the column index is out of range" do
      expect(subject.column(380)).to eq([])
    end
  end
  
  describe "#row" do
    it "returns an array of elements comprising requested row" do
      expect(subject.row(1)).to eq([0, 0, 0, 1, 1, 0, 0, 1])
      expect(subject.row(8)).to eq([0, 0, 0, 0, 0, 1, 0, 0])
    end
    it "returns an empty array if the row index is out of range" do
      expect(subject.row(380)).to eq([])
    end
  end


end