#
#https://github.com/mikel/mail
#
require 'roo-xls'

require 'mail'
load "/home/haritak/my_work/school/myschool-ruby-scripts/list-monitoring/forbiden"

programmers = ["charitakis.ioannis@gmail.com",
               "tkodellas@gmail.com",
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

Mail.all.each do |m|

  sender = m.from
  puts
  puts "-----"
  puts m.from
  puts m.subject


  if programmers.map{|p| sender.include? p}.include?(true)
    puts "sent from programmers"

    titleHintsSchedule = (m.subject =~ /^\[Λίστα ΕΠΑΛ\].*ρολ.γιο.*/)
    puts "Title hints this is the schedule" if titleHintsSchedule

    xlsFound = false

    m.attachments.each do |a|
      filename = a.filename
      if filename =~ /EXCEL\.xls/
        xlsFound = true
        puts "Schedule EXCEL.xls found. Saving"
        File.open("GroupFixer/EXCEL.xls", "w+b", 0644) {|f| f.write a.body.decoded}

        xls = Roo::Spreadsheet.open("GroupFixer/EXCEL.xls")
        sheet = xls.sheet(0)
        sheet.each_with_index do |r,i|
          puts i
          puts r[0]
        end
        %x{ cd GroupFixer && php groupfixer.php > prepared.xls }
      else
        puts "ignoring attachment"
      end
    end
    if titleHintsSchedule and !xlsFound
      puts "Missing EXCEL.xls from schedule!"
      next
      Mail.deliver do
        charset = "UTF-8"
        content_transfer_encoding="8bit"
        from 'Αρτέμης Σώρρας <artemis1epalmoiron@gmail.com>'
        to 'epalmoiron.yp@gmail.com'
        cc 'charitakis.ioannis@gmail.com'
        subject 'Λείπει το αρχείο EXCEL.xls'
        text_part do
          content_type "text/plain; charset=utf-8"
          body <<-EOF
Γειά σας,

Πολύ πρόσφατα πήρα απο εσάς ένα email με τίτλο:
'#{m.subject}'
το οποίο για την ακρίβεια έχει σταλεί από :
'#{m.from}
και από τα παραπάνω υπέθεσα ότι περιέχει το Ωρολόγιο Πρόγραμμα.

Λυπάμαι αλλά πρέπει να σας ενημερώσω ότι απο τα αρχεία για το ωρολόγιο
πρόγραμμα που στέιλατε λείπει το EXCEL.xls και υπάρχει πρόβλημα.

Παρακαλώ επαναλάβατε την αποστολή του ωρολόγιου,
συμπεριλαμβάνοντας και το αντίστοιχο EXCEL.xls για να μπορώ να 
δουλέψω και εγώ.

Με τιμή,
Αρτέμης Σώρρας "
          EOF
        end
      end
    end
  end
end

#Mail.find_and_delete
