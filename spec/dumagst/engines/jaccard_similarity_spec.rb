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

  describe "#extract_product_ids" do
    it "returns an array with indices of those elements that were ones in the source array" do
      expect(subject.extract_product_ids([0, 0, 0, 1, 1, 0, 1, 0])).to eq([3, 4, 6])
    end
    it "adjusts the indices by a given number if provided" do
      expect(subject.extract_product_ids([0, 0, 0, 1, 1, 0, 1, 0], 1)).to eq([4, 5, 7])
    end
    it "does not choke on empty arrays" do
      expect(subject.extract_product_ids([], 22)).to eq([])
    end
  end

  describe "#binary_similarity_for" do
  end
end