describe Dumagst::Engines::EngineKeys do
  let(:test_class) do
    Class.new do
      KEY_SEPARATOR = "." unless defined?(KEY_SEPARATOR)
      include Dumagst::Engines::EngineKeys
      def engine_key
        "omg_so_many"
      end
    end
  end
  subject { test_class.new }

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

  describe "#key_for_user" do
    it "returns the key for similar users given user ID" do
      expect(subject.key_for_user(144)).to eq("omg_so_many.similar_users.144")
    end
  end

  describe "key_for_product" do
    it "returns the key for similar products, given user ID" do
      expect(subject.key_for_product(42)).to eq("omg_so_many.similar_products.42")
    end
  end

end