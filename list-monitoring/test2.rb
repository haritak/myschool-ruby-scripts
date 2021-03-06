#
#https://github.com/mikel/mail
#

require 'mail'
load "/home/haritak/my_work/school/myschool-ruby-scripts/list-monitoring/forbiden"

Mail.defaults do
  retriever_method :pop3, :address    => "pop.gmail.com",
                          :port       => 995,
                          :user_name  => USERNAME,
                          :password   => PASSWORD,
                          :enable_ssl => true
end

Mail.all.each do |m|
  puts m.message_id
  puts m.to
  puts m.from
  puts m.cc
  if m.multipart?
    puts "multipart message"
    puts "each part is"
    puts m.parts.length
      m.parts.each do |m|
        puts m.content_type_parameters
    end
  end

end
