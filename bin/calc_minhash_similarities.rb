#!/usr/bin/env ruby
require 'dumagst'
require 'logger'
require 'benchmark'
require(File.join(File.absolute_path(File.dirname(__FILE__)), "config.rb"))

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

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
logger.info "Determining similar products: Minhash Engine"
logger.info "Input file : #{File.absolute_path(input_filename)}"
logger.info "Matrix dimensions: #{dimensions[0]} products by #{dimensions[1]} users"
Dumagst.configuration.redis_connection.flushdb
matrix = Dumagst::Matrices::NativeMatrix.from_csv(input_filename, dimensions[0], dimensions[1])
engine = Dumagst::Engines::MinhashEngine.new(
  engine_key: "jaccard_minhash_similarity", 
  matrix: matrix, 
  similarity_threshold: 0.85,
  buckets: 250
)
Benchmark.bm do |x|
  x.report { engine.process }
end

logger.info "Done."
