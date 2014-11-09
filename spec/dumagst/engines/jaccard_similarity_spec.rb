describe Dumagst::Engines::JaccardSimilarity do
  let(:test_class) do
    Class.new do
      include Dumagst::Engines::JaccardSimilarity
    end
  end
  subject { test_class.new }
  describe "#similarity_for" do
    it "calculates similarity for two arrays correctly" do
      sim = subject.similarity_for(
        [1, 3, 5, 7, 42],
        [3, 42, -14, 1, 8, 144]
      )
      expect(sim).to eq(3.0 / 8)
    end
    it "calculates similarity correctly if one of arrays is empty" do
      sim = subject.similarity_for(
        [1, 3, 5, 7, 42],
        []
      )
      expect(sim).to eq(0)

    end
    it "returns zero if arrays have no common elements" do
      sim = subject.similarity_for(
        [1, 3, 5, 7],
        [2, 4, 6]
      )
      expect(sim).to eq(0)
    end
    it "returns zero if both arrays are empty" do
      expect(subject.similarity_for([], [])).to eq(0)
    end
  end

  describe "#binary_similarity_for" do
  end
end