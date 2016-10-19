#https://ruby-doc.org/stdlib-1.9.3/libdoc/net/pop/rdoc/Net/POPMail.html
require 'net/pop'
load "/home/haritak/my_work/school/myschool-ruby-scripts/list-monitoring/forbiden"

puts USERNAME
puts PASSWORD

pop = Net::POP3.new('pop.gmail.com')
pop.enable_ssl
pop.start(USERNAME,PASSWORD)             # (1)
if pop.mails.empty?
  puts 'No mail.'
else
  i = 0
  pop.each_mail do |m|   # or "pop.mails.each ..."   # (2)
    puts m.number
    puts m.length
    puts m.size
    puts m.header
    puts m.top(2)
    puts m.unique_id
    s = m.pop
    puts s

    i += 1
  end
  puts "#{pop.mails.size} mails popped."
end
pop.finish       
