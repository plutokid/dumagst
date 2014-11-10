#!/usr/bin/env ruby
require 'dumagst'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

Dumagst.configure do |config|
  config.host = "localhost"
  config.port = 6379
  config.db = 1
end
# filename = File.join(
#   File.dirname(__FILE__),
#   "..",
#   "spec",
#   "fixtures",
#   "products_users_sorted_1656_943.csv"
# )
data_dir = File.join(
  File.dirname(__FILE__),
  "..",
  "data"
)
input_filename = File.join(data_dir, "data.csv")

dimensions_filename = File.join(data_dir, "dimensions.csv")

dimensions = []
CSV.foreach(dimensions_filename, "r") do |row|
  dimensions = [row[0].to_i, row[1].to_i]
end
logger.info "Determining similar products: Jaccard Engine"
logger.info "Input file : #{File.absolute_path(input_filename)}"
logger.info "Matrix dimensions: #{dimensions[0]} products by #{dimensions[1]} users"
Dumagst.configuration.redis_connection.flushdb
matrix = Dumagst::Matrices::NativeMatrix.from_csv(input_filename, dimensions[0], dimensions[1])
engine = Dumagst::Engines::JaccardEngine.new(engine_key: "jaccard_native_similarity", matrix: matrix, similarity_threshold: 0.5)

engine.process

logger.info "Done."