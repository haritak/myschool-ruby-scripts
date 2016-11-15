#
#https://github.com/mikel/mail
#
require 'pry'
require 'roo-xls'

require 'mail'
load "forbiden"

raise "Configuration error, check SCHEDULE_ARCHIVE" unless File.exist?(SCHEDULE_ARCHIVE)
raise "Configuration error, check TESTING" unless TESTING==false or TESTING==true

ME = "artemis1epalmoiron@gmail.com"

$programmers = ["charitakis.ioannis@gmail.com",
               "tkodellas@gmail.com",
               "glemon1@gmail.com",
               "manosski@yahoo.com",
               "epalmoiron.yp@gmail.com"]

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

def saveLocal(attachment)
  filename = attachment.filename
  if not File.exist?("tmp/")
    FileUtils.mkdir("tmp")
  end
  FileUtils.rm("tmp/#{filename}") if File.exist?("tmp/#{filename}")

  File.open("tmp/#{filename}", "w+b", 0644) {|f| f.write attachment.body.decoded}
end

def informSchedulersOfMissing(email, missingFiles)
  missing_files = missingFiles.join(",")
  Mail.deliver do
    charset = "UTF-8"
    content_transfer_encoding="8bit"
    from 'Αρτέμης Μάτσας <artemis1epalmoiron@gmail.com>'
    if not TESTING
      to 'tkodellas@gmail.com'
      cc $programmers.join(",")
    else
      to 'charitakis.ioannis@gmail.com'
      cc 'bp10.charitakis@gmail.com,tmp123@ych.gr'
    end
    subject 'Λείπουν αρχεία!'
    text_part do
      content_type "text/plain; charset=utf-8"
      body <<-EOF
Γειά σας,

Πολύ πρόσφατα πήρα απο εσάς ένα email με τίτλο:
'#{email.subject}'
το οποίο για την ακρίβεια έχει σταλεί από :
'#{email.from}'
και από τα παραπάνω υπέθεσα ότι περιέχει το Ωρολόγιο Πρόγραμμα.

Πρέπει να σας ενημερώσω ότι απο τα αρχεία για το ωρολόγιο
πρόγραμμα που στέιλατε λείπουν τα παρακάτω:
'#{missing_files}'

Παρακαλώ επαναλάβατε την αποστολή του ωρολόγιου,
συμπεριλαμβάνοντας ότι λείπει για να μπορώ να δουλέψω και εγώ.

Με τιμή,
Αρτέμης Μάτσας
υγ: Το email περιλαμβάνει στους παραλήπτες όλους όσους
ασχολούνται με το ωρολόγιο πρόγραμμα.
      EOF
    end
  end
end

def informProgramOk
  Mail.deliver do
    charset = "UTF-8"
    content_transfer_encoding="8bit"
    from 'Αρτέμης Μάτσας <artemis1epalmoiron@gmail.com>'
    if not TESTING
      to 'tkodellas@gmail.com'
      cc $programmers.join(",")
    else
      to 'charitakis.ioannis@gmail.com'
      cc 'bp10.charitakis@gmail.com,tmp123@ych.gr'
    end
    subject 'Το πρόγραμμα δημοσιεύθηκε!'
    text_part do
      content_type "text/plain; charset=utf-8"
      body <<-EOF
Γειά σας,

Δημοσίευσα το ωρολόγιο πρόγραμμα!

Παρακαλώ κάντε έναν έλεγχο ότι όλα είναι εντάξει!

http://srv-1tee-moiron.ira.sch.gr/epalmoiron/wordpress/?page_id=966

Με τιμή,
Αρτέμης Μάτσας
υγ: Το email περιλαμβάνει στους παραλήπτες όλους όσους
ασχολούνται με το ωρολόγιο πρόγραμμα.
      EOF
    end
  end
end


def emailFile(filename)
  Mail.deliver do
    charset = "UTF-8"
    content_transfer_encoding="8bit"
    from 'Αρτέμης Μάτσας <artemis1epalmoiron@gmail.com>'
    if TESTING
      to 'charitakis.ioannis@gmail.com'
    else 
      to '1epal-moiron-dev@googlegroups.com'
    end
    time = Time.new
    subject "Ετοιμο αρχείο READY.xls για αυτά που πήρα στις #{time.day}-#{time.month}"
    add_file filename
    text_part do
      content_type "text/plain; charset=utf-8"
      body <<-EOF
Γειά σας,

Είμαι στην ευχάριστη θέσης να σας στείλω τα groupakia.
Χρειάζονται λίγη δουλίτσα ακόμα.

Μπορείτε να ρυθμίσετε ποιοι θα είναι στα group εδώ:
http://srv-1tee-moiron.ira.sch.gr:4567/ αλλά
μετά θα πρέπει να μου στείλετε (σε εμένα, όχι σε λίστα) άλλο ένα email
με συννημμένο το αρχείο EXCEL.xls 
έτσι ώστε να ξαναπιάσω δουλειά.

Με τιμή,
Αρτέμης Μάτσας
      EOF
    end
  end
end

puts "Starting email processing..."
Mail.all.each do |m|

  sender = m.from
  recipients = "#{m.to} #{m.cc} #{m.bcc}"
  personal = recipients.include?(ME)
  puts
  puts "-----"
  puts sender
  puts m.subject
  puts recipients


  if $programmers.map{|p| sender.include? p}.include?(true)
    puts "This email was sent from one of the persons that works on the schedule"

    puts "This email was specifically sent to me" if personal

    titleHintsSchedule = (m.subject =~ /.*ρολ.γιο.*ρ.γραμ.*/)
    puts "Title hints this is the schedule" if titleHintsSchedule

    xlsFound = false
    foundFiles = []
    notFoundFiles = [
      "EXCEL.xls",
      "TEACHERS.pdf",
      "TEACHERS_DETAILED.pdf",
      "STUDENTS.pdf",
      "STUDENTS_DETAILED.pdf",
      "ROOMS.pdf",
      "ROOMS_DETAILED.pdf",
      "KATANOMI.xls",
      "roz file (AscTimetables file)"]

    rozFilename = ''

    m.attachments.each do |a|
      filename = a.filename
      saveLocal(a)
      puts "New attachment #{filename}"
      foundFiles << notFoundFiles.select { |f| filename =~ /#{Regexp.escape(f)}/ } 
      if filename =~ /.*roz/
        foundFiles << filename
        rozFilename = filename
        notFoundFiles = notFoundFiles - ["roz file (AscTimetables file)"]
      end
      if filename =~ /EXCEL\.xls/
        xlsFound = true
        puts "Schedule EXCEL.xls found. Saving"

        if File.exist?('GroupFixer/EXCEL.xls') 
          FileUtils.rm('GroupFixer/EXCEL.xls')
        end

        File.open("GroupFixer/EXCEL.xls", "w+b", 0644) {|f| f.write a.body.decoded}

        if File.exist?('GroupFixer/READY.xls') 
          FileUtils.rm('GroupFixer/READY.xls')
        end

        %x{ cd GroupFixer && php groupfixer.php > READY.xls }
        puts "Waiting 5 seconds for previous operation to finish"
        sleep 5
        if File.exist?('GroupFixer/READY.xls')
          emailFile('GroupFixer/READY.xls')
        else
          puts "TODO - κάτι στράβωσε στην δημιουργία τους READY.xls"
        end
      end #matches xls
    end # each attachment

    foundFiles.flatten!

    notFoundFiles = notFoundFiles - foundFiles

    if titleHintsSchedule then
      if  notFoundFiles.size!=0
        puts "Missing files"
        puts notFoundFiles
        informSchedulersOfMissing(m, notFoundFiles)
      else 
        if personal
          now = DateTime.now
          next_week = now + 7
          current_year = now.year
          current_week = now.cweek
          next_year = next_week.year
          next_week = next_week.cweek

          pathToNextYear = "#{SCHEDULE_ARCHIVE}/#{next_year}"
          if not File.exist?(pathToNextYear)
            FileUtils.mkdir(pathToNextYear)
          end
          pathToNextWeek = pathToNextYear + "/w#{next_week}"
          if not File.exist?(pathToNextWeek)
            FileUtils.mkdir(pathToNextWeek)
          end
          foundFiles.each do |f|
            FileUtils.mv("tmp/#{f}", pathToNextWeek)
          end
          FileUtils.rm(SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_CURRENT_LINK)
          FileUtils.mv(SCHEDULE_NEXT_LINK, SCHEDULE_CURRENT_LINK) if File.exist?(SCHEDULE_NEXT_LINK)
          FileUtils.ln_s(pathToNextWeek, SCHEDULE_NEXT_LINK)
          FileUtils.cp("index.html", SCHEDULE_NEXT_LINK)
          FileUtils.mv(pathToNextWeek+"/#{rozFilename}", pathToNextWeek+"/FINAL.roz")

          puts "Program published"
          informProgramOk
        end
	end
      end
    end
end

puts "Email process ended"
puts "Deleting emails"
Mail.find_and_delete
puts "Bye!"
