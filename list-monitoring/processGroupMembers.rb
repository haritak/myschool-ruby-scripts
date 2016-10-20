require 'sinatra'
require 'sqlite3'

FileUtils.touch('whosin.db')

db = SQLite3::Database.open "whosin.db"

db.execute "CREATE TABLE IF NOT EXISTS teachers(timetables_name TEXT PRIMARY KEY, using_groups TINYINT)"
stm = db.prepare "SELECT * FROM teachers"
rs = stm.execute

tmp = rs.map{|r| {r[0]=>r[1]} }

allTeachers = {}
tmp.each do |e|
  allTeachers.update(e)
end

puts allTeachers

get '/' do
  toReturn="<ul>"
  allTeachers.each do |t, i|
    toReturn += "<li><a href='/#{t}'>"
    toReturn += "#{t}"
    if i==0
      toReturn += " is excluded"
    else
      toReturn += " is INCLUDED"
    end
    toReturn += "</a></li>"
  end

  toReturn+="</ul>"
end

get '/:teacher_name' do
  params[:teacher_name]
  allTeachers[:teacher_name] = allTeachers[:teacher_name] 
end
