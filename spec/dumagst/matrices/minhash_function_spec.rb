describe Dumagst::Matrices::MinhashFunction do
  describe ".generate" do
    it "returns a MinhashFunction object" do
      expect(Dumagst::Matrices::MinhashFunction.generate(100)).to be_a(Dumagst::Matrices::MinhashFunction)
    end
    it "sets the a, b, and bucket values on the object" do
      f = Dumagst::Matrices::MinhashFunction.generate(100)
      expect(f.buckets).to eq(100)
      expect(f.a).to be_a(Integer)
      expect(f.b).to be_a(Integer)
    end
  end 

  describe "#hash_for" do
    subject { Dumagst::Matrices::MinhashFunction.new(10, 3, 100) }
    it "produces an integer value" do
      expect(subject.hash_for(5)).to eq(53)
    end
    it "wraps over the bucket value" do
      # (10 * 30 + 3) mod 100 = 3
      expect(subject.hash_for(30)).to eq(3)
    end
  end
end