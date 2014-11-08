describe Dumagst::RedisMatrixMapper do
  let(:test_class) {
    Class.new do
      include Dumagst::RedisMatrixMapper
      def redis
        ::Dumagst.configuration.redis_connection
      end
      def key_prefix
        "sample"
      end
    end
  }
  subject { test_class.new }
  describe "#key_for" do
    it "produces the redis key for a matrix element M(x,y) given x and y" do
      expect(subject.key_for(1, 2)).to eq('sample.1.2')
    end
    it "produces the redis key for strings too" do
      expect(subject.key_for("42", "22")).to eq('sample.42.22')
    end
    it "raises if given negative values" do
      expect { subject.key_for(-3, 2)}.to raise_error(KeyError)
      expect { subject.key_for(2, -5)}.to raise_error(KeyError)
    end
    it "raises if given nil values" do
      expect { subject.key_for(nil, 2)}.to raise_error(KeyError)
      expect { subject.key_for(2, nil)}.to raise_error(KeyError)      
    end
  end

  describe "#set_by_key" do
    before(:each) do
      subject.redis.flushdb
    end
    it "writes the value specified for the x,y" do
      subject.set_by_key(42, 21, 0.888)
      expect(subject.get_by_key(42, 21)).to eq(0.888)
    end
  end

  describe "#get_by_key" do
    before(:each) do
      subject.redis.flushdb
    end
    it "returns nil if no value has been stored under the key for x and y" do
      expect(subject.get_by_key(2, 3)).to eq(nil)
    end
  end

  describe "#row_pattern" do
    it "returns the pattern to select keys for given row" do
      expect(subject.row_pattern(4)).to eq("sample.4.*")
    end
  end

  describe "#column_pattern" do
    it "returns the pattern to select keys for given column" do
      expect(subject.column_pattern(42)).to eq("sample.*.42")
    end
  end

  describe "reverse_key" do
    it "given a key, returns the array of [row, column] integers" do
      expect(subject.reverse_key("sample.12.34")).to eq([12, 34])
    end
    it "raises given invalid key(s)" do
      expect { subject.reverse_key("ohnoes")}.to raise_error
      expect { subject.reverse_key("ohnoes.1")}.to raise_error
    end
  end
end