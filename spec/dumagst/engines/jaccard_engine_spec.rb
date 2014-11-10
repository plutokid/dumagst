describe Dumagst::Engines::JaccardEngine do
  let(:csv_file) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "jaccard_10.csv") }
  describe "#recommend_users" do
    context "with a redis matrix" do
      let(:matrix) { Dumagst::Matrices::RedisMatrix.from_csv(csv_file) }
      before(:each) { Dumagst.configuration.redis_connection.flushdb }
      subject { Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.2)}
      it "returns a set of user ids ordered by similarity" do
        subject.process
        expect(subject.recommend_users(1)).to eq([4, 3, 2])
        expect(subject.recommend_users(2)).to eq([6, 1, 4])
        expect(subject.recommend_users(6)).to eq([2])
      end
      it "returns an empty array if there are no similar users" do
        engine = Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.4)
        engine.process
        expect(engine.recommend_users(6)).to eq([])
      end
    end
    context "with a native matrix" do
      let(:matrix) { Dumagst::Matrices::NativeMatrix.from_csv(csv_file, 9, 8) }
      before(:each) { Dumagst.configuration.redis_connection.flushdb }
      subject { Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.2)}
      it "returns a set of user ids ordered by similarity" do
        subject.process
        expect(subject.recommend_users(1)).to eq([4, 3, 2])
        expect(subject.recommend_users(2)).to eq([6, 1, 4])
        expect(subject.recommend_users(6)).to eq([2])
      end
      it "returns an empty array if there are no similar users" do
        engine = Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.4)
        engine.process
        expect(engine.recommend_users(6)).to eq([])
      end
    end
  end
  describe "#recommend_products" do
    context "with a native matrix" do
      before(:each) { Dumagst.configuration.redis_connection.flushdb }
      let(:matrix) { Dumagst::Matrices::NativeMatrix.from_csv(csv_file, 9, 8) }
      subject { Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.2)}
      it "returns a set of products that the user might like given the user ID" do
        expect(subject.recommend_products(1)).to eq([4, 3, 2])
        puts "ulala"
      end
    end    
  end
end