require 'rubygems'
require 'roo'

DaysColumn = 1
LocationsColumn = 2
NoIntermissions = 6
NoLocations = 5 #Είσοδος, Οροφος ... **και** το Αναπληρωτής

weekdays = ["Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή"]

intermissions = {}
locations = {}
teachers = []
dayrows = {}

oo = Roo::Spreadsheet.open("example.ods")

sheet = oo.sheet(0)

column = sheet.column(DaysColumn)
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
      puts "Error! #{cell} occurs twice in the same row"
      exit
    else
      intermissions[cell] = i
    end
  end
end

if intermissions.size != NoIntermissions 
  puts "Warning! found less than expected intermissions."
  exit
else
  puts "Number of intermissions seems ok"
end


column = sheet.column(LocationsColumn)
column.each_with_index do |cell,i|
  if cell.class != String
    next
  end
  if locations[cell] != nil
    locations[cell] << i
  else
    locations[cell] = [i]
  end
end

locations.each do |k,v|
  if v.size != weekdays.size
    locations.delete(k)
  end
end

if locations.size == NoLocations
  puts "All locations were found"
else
  puts "Warning! Didn't find all locations"
  exit
end

#find teachers

columnOfFirstIntermission = intermissions.values[0]+1
columnOfLastIntermission = intermissions.values[-1]+1
rowOfFirstDayFirstPlace = intermissions_row_no + 1
rowOfLastDayLastPlace = dayrows[ weekdays[4] ][-1] + 1

puts "Teachers names should be inside the box "+
  "#{rowOfFirstDayFirstPlace},#{columnOfFirstIntermission} and "+
  "#{rowOfLastDayLastPlace}, #{columnOfLastIntermission}"

current_row_no = rowOfFirstDayFirstPlace
while current_row_no <= rowOfLastDayLastPlace
  current_column_no = columnOfFirstIntermission
  while current_column_no<=columnOfLastIntermission
    cell = sheet.cell(current_row_no, current_column_no)
    teachers<<cell unless teachers.include?(cell)
    current_column_no+=1
  end
  current_row_no+=1
end

puts "#{teachers.size} teachers found"
total_efimeries = locations.size * intermissions.size
puts "#{total_efimeries} are the total number of efimeries"
efimeries_per_person = ((total_efimeries.to_f/teachers.size) + 0.5).round
puts "#{efimeries_per_person} efimeries should receive each person per day"
puts "#{efimeries_per_person*5} efimeries should receive each person per week"
 


dayrows.each do |day,rows|
end




