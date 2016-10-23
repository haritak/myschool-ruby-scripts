require 'sinatra'
require 'sqlite3'

set :bind, '0.0.0.0'

FileUtils.touch('whosin.db')

db = SQLite3::Database.open "whosin.db"
db.execute "CREATE TABLE IF NOT EXISTS teachers(timetables_name TEXT PRIMARY KEY, using_groups TINYINT)"

allTeachers={}

def refreshAllTeachers(db, allTeachers)
  stm = db.prepare "SELECT * FROM teachers"
  rs = stm.execute

  tmp = rs.map{|r| {r[0]=>r[1]} }

  tmp.each do |e|
    allTeachers.update(e)
  end
end

refreshAllTeachers(db, allTeachers)
puts allTeachers

get '/' do
  refreshAllTeachers(db, allTeachers)
  puts allTeachers
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
  t = params[:teacher_name]
  redirect '/' unless t
  allTeachers[t] = (allTeachers[t]+1)%2
  db.execute("UPDATE teachers SET using_groups=#{allTeachers[t]} where timetables_name='#{t}'")
  redirect '/'
end

