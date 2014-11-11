describe Dumagst::Engines::JaccardEngine do
  let(:csv_file) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "jaccard_10.csv") }
  describe "#recommend_users" do
    context "with a redis matrix" do
      let(:matrix) { Dumagst::Matrices::RedisMatrix.from_csv(csv_file) }
      before(:each) { Dumagst.configuration.redis_connection.flushdb }
      subject { Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.2)}
      it "returns a set of similar user objects ordered by similarity with scores" do
        subject.process

        expect(subject.recommend_users(1).map(&:user_id)).to eq([4, 3, 2])
        expect(subject.recommend_users(1).map(&:score)).to eq([400.0, 333.0, 250.0])

        expect(subject.recommend_users(2).map(&:user_id)).to eq([6, 1, 4])
        expect(subject.recommend_users(2).map(&:score)).to eq([333.0, 250.0, 200.0])

        expect(subject.recommend_users(6).map(&:user_id)).to eq([2])
        expect(subject.recommend_users(6).map(&:score)).to eq([333.0])
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
      it "returns a set of similar user objects ordered by similarity with scores" do
        subject.process
        expect(subject.recommend_users(1).map(&:user_id)).to eq([4, 3, 2])
        expect(subject.recommend_users(1).map(&:score)).to eq([400.0, 333.0, 250.0])
        
        expect(subject.recommend_users(2).map(&:user_id)).to eq([6, 1, 4])
        expect(subject.recommend_users(2).map(&:score)).to eq([333.0, 250.0, 200.0])
        
        expect(subject.recommend_users(6).map(&:user_id)).to eq([2])
        expect(subject.recommend_users(6).map(&:score)).to eq([333.0])
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
      it "returns an empty array if there are no matches" do
        subject.process
        expect(subject.recommend_products(22, false)).to eq([])
      end
      it "returns a set of similar products that the user might like given the user ID, excluding user's own likes" do
        subject.process
        #without the filter by own id that would be [9, 3, 2, 1, 5, 7] as the user 1 likes [2,3,5]
        expect(subject.recommend_products(1, false).map(&:product_id)).to eq([9, 1, 7])
      end

      it "returns the set of similar products with scores by default" do
        subject.process
        expect(subject.recommend_products(2).map(&:score)).to eq([333.0, 250.0, 200.0, 200.0, 200.0])
      end
    end    
  end
  describe "#users_with_recommended_products" do
    context "with a native matrix" do
      before(:each) { Dumagst.configuration.redis_connection.flushdb }
      let(:matrix) { Dumagst::Matrices::NativeMatrix.from_csv(csv_file, 9, 8) }
      subject { Dumagst::Engines::JaccardEngine.new(matrix: matrix, similarity_threshold: 0.4)}
      it "returns the ids of the users that have recommended products" do
        subject.process
        expect(subject.users_with_recommended_products).to eq([8, 1, 4])
      end
    end
  end
end