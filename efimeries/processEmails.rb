require 'sinatra'
require 'sqlite3'

set :bind, '0.0.0.0'
set :port, 3713

FileUtils.touch('emails.db')

db = SQLite3::Database.open "emails.db"
db.execute "CREATE TABLE IF NOT EXISTS teachers(name TEXT PRIMARY KEY, email TEXT)"

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
  allTeachers.each do |t, e|
    toReturn += "<li>"
    toReturn += "<a href='/#{t}'>#{t}</a>"
    toReturn += "</li>"
  end

  toReturn+="</ul>"
end

get '/:teacher_name' do
  t = params[:teacher_name]
  e = params[:email]
  if e==nil
    return tR="<form> "+
    "<input name='email' value='#{allTeachers[t]}'/>"+
    "<button name='submit'>Γράψ'το</button>" +
    "</form>"
  else
    puts "#{t} -> #{e}"
    db.execute("UPDATE teachers "+
               "SET email='#{e}' "+
               "WHERE name='#{t}'")
    redirect '/'
  end
end
