describe Vector do
  describe "#each_index" do
    subject { Vector[11, 22, 33, 44, 55, 66]}
    it "iterates the indices of the vector" do
      expect(subject.each_index.map {|i| i }).to eq([0, 1, 2, 3, 4, 5])
    end
    it "returns an enumerator if a block is not given" do
      expect(subject.each_index).to be_a(Enumerator)
    end
  end
end