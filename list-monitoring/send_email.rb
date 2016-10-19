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
  delivery_method(:smtp, address: "smtp.gmail.com", 
    port: 587, 
    user_name: USERNAME,
    password: PASSWORD,
    authentication: 'plain',
    enable_starttls_auto: true)
end

Mail.deliver do
  to 'charitakis.ioannis@gmail.com'
  from 'artemis1epalmoiron@gmail.com'
  subject 'This is Artemis'
  body 'this is testing'
end
