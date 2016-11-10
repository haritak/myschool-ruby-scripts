require 'rubygems'
require 'roo'

weekdays = ["Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή"]

intermissions = {}
locations = []
teachers = []
dayrows = {}

oo = Roo::Spreadsheet.open("example.ods")

sheet = oo.sheet(0)

column = sheet.column(1)

column.each_with_index do |cell,i|
  if weekdays.include?(cell) then
    if dayrows[cell] != nil
      dayrows[cell] << i
    else
      dayrows[cell] = [i]
    end
  end
end

weekdays.each do |wd|
  if not dayrows.include?(wd)
    puts "#{wd} not found!"
    exit
  end
end

puts "All days were found"

intermissions_row_no = dayrows[weekdays[0]][0]

intermissions_row = sheet.row( intermissions_row_no )

intermissions_row.each_with_index do |cell, i|
  if cell != nil then
    if intermissions[cell] != nil
      intermissions[cell] << i
    else
      intermissions[cell] = [i]
    end
  end
end

if intermissions.size != 6 
  puts "Warning! found less than expected intermissions."
else
  puts "Number of intermissions seems ok"
end


#find locations (column 2)
#
#find teachers

dayrows.each do |day,rows|
end



