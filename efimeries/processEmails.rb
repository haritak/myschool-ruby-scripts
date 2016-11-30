require 'sinatra'
require 'sqlite3'
require 'mail'
load "forbiden"

set :bind, '0.0.0.0'
set :port, 13713

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
    puts e
  end
end

refreshAllTeachers(db, allTeachers)
puts allTeachers

get '/' do
  refreshAllTeachers(db, allTeachers)
  toReturn="<h2>emails προσωπικής ενημέρωσης εφημεριών</h3>"
  toReturn+="<h4>το σύστημα προσωπικής ενημέρωσης είναι<font color=red> υπο δοκιμαστική</font> περίοδο.</h4>"
  toReturn+="<h4>Nα ελέγχετε πάντα τις εφημερίες σας με το επίσημο αρχείο<br> που μας στέλνει ο/η υπεύθυνος/η των εφημεριών.</h4>"
  toReturn+="<table>"
  allTeachers.each do |t, e|
    toReturn += "<tr>"
    toReturn += "<td>#{t}</td><td>#{e}</td><td><a href='/#{t}'>Καταχώριση/ενημέρωση email.</a></td>"
    toReturn += "</tr>"
  end

  toReturn+="</table>"
end

get '/:teacher_name' do
  t = params[:teacher_name]
  e = params[:email]
  if e==nil
    return tR="<form> "+
    "email:<input name='email' value='#{allTeachers[t]}'/>"+
    "<button name='submit'>Αποθήκευσέ τo email μου</button>"
    #+"</form><a href='/#{t}/send_efimeries'>Στείλε μου τις εφημερίες μου</a>"
  else
    puts "#{t} -> #{e}"
    db.execute("UPDATE teachers "+
               "SET email='#{e}' "+
               "WHERE name='#{t}'")
    redirect '/'
  end
end

Mail.defaults do
  retriever_method :imap, 
    :address    => "imap.googlemail.com",
    :port       => 993,
    :user_name  => USERNAME,
    :password   => PASSWORD,
    :enable_ssl => true

  delivery_method(:smtp, 
                  address: "smtp.gmail.com", 
                  port: 587, 
                  user_name: USERNAME,
                  password: PASSWORD,
                  authentication: 'plain',
                  enable_starttls_auto: true)
end

def beautify(efimeria)
end

def sendEmail(teacher, email, efimeries)
  if email!=nil and email.strip != ''
    puts "Will send an email to #{email} which corresponds to #{teacher}."
    efimeries.each do |e|
      print beautify(e)
      puts
    end
    puts ""
    puts "-------------------"
  end
end

get '/:teacher_name/send_efimeries' do
  t = params[:teacher_name]
  e = allTeachers[t]
  sendEmail(t, e, ["monday", "eisodos", "1"])
  redirect '/'
end
