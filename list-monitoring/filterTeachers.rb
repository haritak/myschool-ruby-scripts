require 'roo-xls'
require 'fileutils'
require 'sqlite3'

FileUtils.touch('whosin.db')

db = SQLite3::Database.open "whosin.db"
db.execute "CREATE TABLE IF NOT EXISTS teachers(timetables_name TEXT PRIMARY KEY, using_groups TINYINT)"
stm = db.prepare "SELECT * FROM teachers"
rs = stm.execute

initializeDb = true
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
    teachers = rs.map {|r| r[0]}
  end
  p teachers

  stm.close
end

xls = Roo::Spreadsheet.open("GroupFixer/EXCEL.xls")
sheet = xls.sheet(0)
sheet.each_with_index do |r,i|
  next if not r[0] or r[0].chomp == "" 
  puts "--#{r[0]}--"

  if initializeDb or not allTeachers.include?(r[0])
    begin
      db.execute "INSERT INTO teachers VALUES('#{r[0]}',0)"
    rescue SQLite3::ConstraintException => e
      puts e
      puts "ignoring..."
    end
  end
end

db.close
