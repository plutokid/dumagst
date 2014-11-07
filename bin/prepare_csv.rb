#!/usr/bin/env ruby
require 'csv'
require 'yaml'
input_filename = ARGV[0] || "./data/u.data"
output_filename = ARGV[1] || "./data/data.csv"
threshold = (ARGV[2] || 4).to_i

output_file = CSV.open(output_filename, "wb")
total_count = 0
liked_count = 0
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
  end
end

output_file.close

users.uniq!
products.uniq!
avg_liked = products_per_user.values.inject{ |sum, el| sum + el }.to_f / products_per_user.values.size

puts "Processed #{total_count} records, produced #{liked_count} user like records. Total users #{users.count}, total products #{products.count}, average of #{avg_liked} per user"