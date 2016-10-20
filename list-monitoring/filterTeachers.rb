require 'roo-xls'
require 'fileutils'
require 'sqlite3'
#https://github.com/zdavatz/spreadsheet/blob/master/GUIDE.md
require 'spreadsheet'

FileUtils.touch('whosin.db')

db = SQLite3::Database.open "whosin.db"
db.execute "CREATE TABLE IF NOT EXISTS teachers(timetables_name TEXT PRIMARY KEY, using_groups TINYINT)"
stm = db.prepare "SELECT * FROM teachers"
rs = stm.execute

initializeDb = false
allTeachers=[]

if rs.eof?
  puts "No teachers registered"
  puts "Will initialize the database"
  initializeDb = true
else
    allTeachers = rs.map {|r| r[0]}
end

stm.close

teachers=[]
if not initializeDb
  stm = db.prepare "SELECT * FROM teachers WHERE using_groups=1"
  rs = stm.execute

  if rs.eof?
    puts "No need to do anything. Noone is using the groups"
  else
    teachers= rs.map {|r| r[0].tr('/','_')} #replace / because it causes illegal URLs
  end

  stm.close
end

p teachers

xls = Roo::Spreadsheet.open("GroupFixer/EXCEL.xls")
Spreadsheet.client_encoding = 'UTF-8'
new_xls = Spreadsheet::Workbook.new
new_sheet = new_xls.create_worksheet

sheet = xls.sheet(0)
new_i=0
sheet.each_with_index do |r,i|
  next if not r[0] or r[0].chomp == "" 
  r[0].tr!('/','_') #avoid bad urls
  puts "--#{r[0]}--"

  if initializeDb or not allTeachers.include?(r[0])
    begin
      db.execute "INSERT INTO teachers VALUES('#{r[0]}',0)"
    rescue SQLite3::ConstraintException => e
      puts e
      puts "ignoring..."
    end
  end

  if teachers.include?(r[0])
    puts "Teacher #{r[0]} included in groups"
    new_sheet.insert_row new_i, r
    new_i+=1
  end
end
new_xls.write("GroupFixer/PROCESSED.xls")

db.close
