#!/usr/bin/env ruby
require 'csv'
require 'yaml'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

dirname = File.dirname(__FILE__)
input_filename = ARGV[0] || File.join(dirname, "..", "data", "ml-100k", "u.data")
output_filename = ARGV[1] || File.join(dirname, "..", "data", "data.csv")
metadata_filename = File.join(File.dirname(output_filename), "dimensions.csv")
#fixture_filename = File.join(dirname, "..", "spec", "fixtures", "products_users.csv")
threshold = (ARGV[2] || 3).to_i

output_file = CSV.open(output_filename, "wb")
#fixtures_file = CSV.open(fixture_filename, "wb")
total_count = 0
liked_count = 0
fixtures_count = 0
users = []
products = []
products_per_user = {}

logger.info "processing movie ratings:"
logger.debug "input file : #{File.absolute_path(input_filename)}"
logger.debug "output file : #{File.absolute_path(output_filename)}"
logger.debug "minimal rating to be considered a like : #{threshold}"

CSV.foreach(input_filename, col_sep: "\t") do |row|
  total_count += 1
  #user id | item id | rating | timestamp.
  if row[2].to_i >= threshold
    # save as item_id | user_id
    output_file << [row[1], row[0]]
    liked_count +=1
    users << row[0]
    products << row[1]
    products_per_user[row[0]] ||= 0
    products_per_user[row[0]] = products_per_user[row[0]] + 1
    # write every 20th record into the fixture file
    # if total_count % 20 == 0
    #   fixtures_file << [row[1], row[0]]
    #   fixtures_count += 1
    # end
    logger.info "Processed #{total_count} records " if total_count % 10000 == 0
  end
end

output_file.close
#fixtures_file.close
max_user = users.max_by {|id| id.to_i}
max_product = products.max_by {|id| id.to_i}

CSV.open(metadata_filename, "wb") do |csv|
  csv << [max_product, max_user]
end

users.uniq!
products.uniq!
avg_liked = products_per_user.values.inject{ |sum, el| sum + el }.to_f / products_per_user.values.size

logger.info "Processed #{total_count} records, produced #{liked_count} user like records. Total users #{users.count}, total products #{products.count}, average of #{avg_liked} per user"
logger.info "Matrix dimensions : #{max_product} products by #{max_user} users"
#puts "Saved #{fixtures_count} records to the fixture file #{File.absolute_path(fixture_filename)}"