#!/usr/bin/ruby
#


all = Dir.glob("combined/*")

all.each do |file|

  basename =  File.basename(file,".*")

  cmd = "pdfseparate #{file} splitted/#{basename}-%d.pdf"
  p cmd
  `#{cmd}`

end




