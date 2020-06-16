#!/usr/bin/ruby
require 'csv'
require 'open3'

a = CSV.read("db.csv")
db = {}

puts "Parsing db.csv"
a.each do |line|
  #p line
  next if not line[1]
  #p line[1]
  
  if db[ line[1] ]
    puts "Error! Duplicate AM?"
    exit
  end
  db[ line[1] ] = line[-1]
end

puts "Parsing of DB ended"

p db

puts "Finished"

original_pdfs = Dir.glob("splitted/*pdf")
original_pdfs.each do |filename|
  basename = File.basename(filename,".pdf")
  stdout, stderr, status = Open3.capture3("pdftotext #{filename} - | sed '15,23!d' - | grep ^[0-9] ")
  p stdout
  am = stdout[/\d+/]
  trg_filename = db[ am ]
  puts "Found: #{basename}, #{am}, #{trg_filename}"
  if am.length != 3 and am.length != 4
    puts "Error detected"
    exit
  end

  `cp #{filename} renamed/#{trg_filename}`
end


