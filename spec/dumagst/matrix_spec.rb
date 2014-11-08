describe Dumagst::Matrix do
  subject { Dumagst::Matrix.new(1000, 1000) }
  describe "#[]" do
    before(:each) { subject.send(:redis).flushdb }
    it "returns zero if the element has not been set" do
      expect(subject[1, 2]).to eq(0.0)
    end
    it "returns the value for x,y if set before" do
      subject[1, 42] = 1
      expect(subject[1, 42]).to eq(1)
    end
  end
end