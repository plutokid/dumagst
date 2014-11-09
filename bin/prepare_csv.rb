#!/usr/bin/env ruby
require 'csv'
require 'yaml'
dirname = File.dirname(__FILE__)
input_filename = ARGV[0] || File.join(dirname, "..", "ml-100k", "data", "u.data")
output_filename = ARGV[1] || File.join(dirname, "..", "data", "data.csv")
#fixture_filename = File.join(dirname, "..", "spec", "fixtures", "products_users.csv")
threshold = (ARGV[2] || 4).to_i

output_file = CSV.open(output_filename, "wb")
#fixtures_file = CSV.open(fixture_filename, "wb")
total_count = 0
liked_count = 0
fixtures_count = 0
users = []
products = []
products_per_user = {}

CSV.foreach(input_filename, col_sep: "\t") do |row|
  total_count += 1
  #user id | item id | rating | timestamp.
  if row[2].to_i > threshold
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
  end
end

output_file.close
#fixtures_file.close

users.uniq!
products.uniq!
avg_liked = products_per_user.values.inject{ |sum, el| sum + el }.to_f / products_per_user.values.size

puts "Processed #{total_count} records, produced #{liked_count} user like records. Total users #{users.count}, total products #{products.count}, average of #{avg_liked} per user"
#puts "Saved #{fixtures_count} records to the fixture file #{File.absolute_path(fixture_filename)}"