require 'rubygems'
require 'roo'
require 'sqlite3'

require 'mail'
load "forbiden"
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

DaysColumn = 1
LocationsColumn = 2
NoIntermissions = 6
NoLocations = 5 #Είσοδος, Οροφος ... **και** το Αναπληρωτής

weekdays = ["Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή"]

intermissions = {}
locations = {}
teachers = []
dayrows = {}

oo = Roo::Spreadsheet.open("efimeries.ods")

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

p dayrows

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

column2intermission={}
intermissions.each do |k,v|
  colNo = v+1
  if column2intermission[colNo] != nil
    puts "Error! Duplicate v for intermission"
    exit
  end
  column2intermission[colNo] = k
end
#p column2intermission

row2location = {}
locations.each do |k,v|
  v.each do |r|
    rowNo=r+1
    if row2location[rowNo] != nil
      puts "Error! Duplicate v for location"
    end
    row2location[rowNo] = k
  end
end
#p row2location

row2day={}
dayrows.each do |k,v|
  v.each do |r|
    rowNo=r+1
    if row2day[rowNo] != nil
      puts "Error! Duplicate v for day"
    end
    row2day[rowNo] = k
  end
end
#p row2day

current_row_no = rowOfFirstDayFirstPlace
while current_row_no <= rowOfLastDayLastPlace
  current_column_no = columnOfFirstIntermission
  while current_column_no<=columnOfLastIntermission
    cell = sheet.cell(current_row_no, current_column_no)
    cell.strip!
    teachers<<cell unless teachers.include?(cell)
    current_column_no+=1
  end
  current_row_no+=1
end

puts "#{teachers.size} teachers found"
total_efimeries_per_day = locations.size * intermissions.size
puts "#{total_efimeries_per_day} are the total number of efimeries"
efimeries_per_person = ((total_efimeries_per_day.to_f/teachers.size) + 0.5).round
puts "#{efimeries_per_person} efimeries should receive each person per day"
puts "#{efimeries_per_person*5} efimeries should receive each person per week"

efimeriesPerTeacher = {}
teachers.each do |teacher|

  current_row_no = rowOfFirstDayFirstPlace
  while current_row_no <= rowOfLastDayLastPlace
    current_column_no = columnOfFirstIntermission
    while current_column_no<=columnOfLastIntermission
      cell = sheet.cell(current_row_no, current_column_no)

      if cell==teacher
        theDay = row2day[ current_row_no ]
        theLocation = row2location[ current_row_no ]
        theIntermission = column2intermission[ current_column_no ]
        if theDay==nil or theLocation==nil or theIntermission==nil
          puts "Miss hit!"
          exit
        end
        efimeriesPerTeacher[teacher] = [] if efimeriesPerTeacher[teacher] == nil
        efimeriesPerTeacher[teacher] << [theDay, theLocation,theIntermission]
      end
      
      current_column_no+=1
    end
    current_row_no+=1
  end
end

totalEfimeries = 0
countEfimeriesPerTeacher = {}
efimeriesPerTeacher.each do |k,v|
  puts k
  v.each do |l|
    p l
  end
  countEfimeriesPerTeacher[ k ] = v.size
  totalEfimeries+=v.size
  puts "-----"
end

p countEfimeriesPerTeacher
puts "#{totalEfimeries} efimeries have been assigned"
if totalEfimeries!=total_efimeries_per_day*5
  puts "Consistency error!"
end
 
puts "Updating emails.db"
FileUtils.touch('emails.db')
db = SQLite3::Database.open "emails.db"
db.execute "CREATE TABLE IF NOT EXISTS teachers(name TEXT PRIMARY KEY, email TEXT)"
stm = db.prepare "SELECT * FROM teachers"
rs = stm.execute

stm.close
teachers.each do |teacher|
  teacher.strip!
  begin
    db.execute "INSERT INTO teachers VALUES('#{teacher}','')"
  rescue SQLite3::ConstraintException => e
    puts e
    puts "ignoring..."
  end
end
puts "Update of emails.db finished"

emailsPerTeacher={}
stm = db.prepare "SELECT * FROM teachers"
rs = stm.execute
tmp = rs.map{|r| {r[0]=>r[1]} }
tmp.each do |e|
  emailsPerTeacher.update(e)
end

def beautify(efimeria)
  ef=""
  efimeria.each_with_index do |k,i|
    if i==0
      ef +="#{k}: "
    else
      ef +="#{k} "
    end
  end
  ef
end

def sendEmail(teacher, email, efimeries)
  if email!=nil and email.strip != ''
    emailContent=''
    efimeries.each do |e|
      emailContent += beautify(e)
      emailContent += "\n"
    end
    Mail.deliver do
      charset = "UTF-8"
      content_transfer_encoding="8bit"
      from 'Αρτέμης <artemis1epalmoiron@gmail.com>'
      if not TESTING
        to email
      else
        to 'charitakis.ioannis@gmail.com'
      end
      subject "#{teacher} Προσωπικές εφημερίες (αυτόματο email)"
      add_file 'efimeries.ods'
      text_part do
        content_type "text/plain; charset=utf-8"
        body <<-EOF

#{teacher},
 
Κοιτώντας την λίστα αλληλογραφίας του ΕΠΑΛ Μοιρών ([Λίστα ΕΠΑΛ]),
παρατήρησα ότι παραλάβαμε νέες εφημερίες.

Κατόπιν της δικής σας επιθυμίας σας συνοψίζω τί αφορά εσάς:


Εφημερίες για #{teacher}

#{emailContent}
-----------------

Παρακαλώ, επιβεβαιώστε ότι τις έχω εντοπίσει σωστά,
συγκρίνοντας με το αρχείο που έστειλε ο/η υπεύθυνος/η των εφημεριών.

Επίσης, παρακαλώ μην στηρίζεστε πάνω μου για την ενημέρωση των
εφημεριών σας. Είμαι ένα απλό πρόγραμμα. Μερικές φορές μπορεί
να κολλήσω και να μην σας στείλω τίποτα ή να σας στείλω
άλλα 'ντ' αλλων.

Με τιμή,
Αρτέμης 

        EOF
      end#text_part
      puts "Sent an email to #{email} which corresponds to #{teacher}."
    end#Mail.deliver
  end
end

emailsPerTeacher.each do |k,v|
  puts "#{k}->#{v}"
  efimeries = efimeriesPerTeacher[k]

  if v!=nil and v!=''
    if efimeries!=nil
      sendEmail(k, v, efimeries)
    else
      puts "-none"
    end
  end
end
