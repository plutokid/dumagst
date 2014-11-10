#!/usr/bin/env ruby
require 'dumagst'

Dumagst.configure do |config|
  config.host = "localhost"
  config.port = 6379
  config.db = 1
end
filename = File.join(
  File.dirname(__FILE__),
  "..",
  "spec",
  "fixtures",
  "products_users_sorted_1656_943.csv"
)
Dumagst.configuration.redis_connection.flushdb
matrix = Dumagst::Matrices::NativeMatrix.from_csv(filename, 1656, 943)
engine = Dumagst::Engines::JaccardEngine.new(engine_key: "jaccard_native_similarity", matrix: matrix, similarity_threshold: 0.5)

engine.process