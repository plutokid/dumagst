#!/usr/bin/env ruby
require 'csv'
input_filename = ARGV[0] || "u.data"
output_filename = ARGV[1] || "data.csv"
threshold = (ARGV[2] || 4).to_i

output_file = CSV.open(output_filename, "wb")
total_count = 0
liked_count = 0
CSV.foreach(input_filename, col_sep: "\t") do |row|
  total_count += 1
  if row[2].to_i >= threshold
    output_file << [row[0], row[1]]
    liked_count +=1
  end
end

output_file.close

puts "Processed #{total_count} records, produced #{liked_count} user like records."