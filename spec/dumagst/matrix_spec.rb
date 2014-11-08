describe Dumagst::Matrix do
  subject { Dumagst::Matrix.new }
  describe "#[]" do
    before(:each) { subject.send(:redis).flushdb }
    it "returns zero if the element has not been set" do
      expect(subject[1, 2]).to eq(0.0)
    end
    it "returns the value for x,y if set before" do
      subject[1, 42] = 1
      expect(subject[1, 42]).to eq(1)
    end
    it "increments the row count if you set an element beyond current dimensions" do
      subject[3, 0] = 1.11
      expect(subject.rows_count).to eq(3)
      subject[8, 2] = 2.11
      expect(subject.rows_count).to eq(8)
    end
    it "increments the column count if you set an element beyond current dimensions" do
      subject[3, 6] = 1.11
      expect(subject.columns_count).to eq(6)
      subject[8, 22] = 2.11
      expect(subject.columns_count).to eq(22)      
    end
  end

  describe ".from_csv" do
    before(:each) { subject.send(:redis).flushdb }
    it "produces a matrix with correct dimensions" do
      csv_file = File.join(File.dirname(__FILE__), "..", "fixtures", "products_users.csv")
      m = Dumagst::Matrix.from_csv(csv_file)
      expect(m).to be_a(Dumagst::Matrix)
      expect(m.dimensions).to eq([1148, 943])
    end
  end
end