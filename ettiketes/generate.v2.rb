require 'rqrcode' #https://github.com/whomwah/rqrcode
require 'prawn/labels' #https://github.com/madriska/prawn-labels
require 'prawn-svg' #https://github.com/mogest/prawn-svg

Prawn::Labels.types = 'custom.yaml'


id = 1234567890
names = []
21.times do
  3.times do |i|
    names  << "#{id}"
  end
  id += 1
end

targets=["ASSET", "ASSET", "RECEIPT"]
tid=0
Prawn::Labels.generate("names.v2.pdf", names, :type => "TypoLabel6511") do |pdf, name|
  #pdf.font "FreeMono.ttf"
  qrcode = RQRCode::QRCode.new("http://srv-1tee-moiron.ira.sch.gr:45537/asset/#{name}")
  svg = qrcode.as_svg
  IO.write("#{name}.svg", svg.to_s)

  pdf.svg IO.read("#{name}.svg"), at: [4,55], width: 50, height: 50
  pdf.draw_text targets[tid], at: [55,40], size: 10
  pdf.draw_text name,  at: [55,30], size: 7
  tid+=1
  if tid>2 then tid=0 end
end
