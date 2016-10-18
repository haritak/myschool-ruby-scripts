require 'rqrcode' #https://github.com/whomwah/rqrcode
require 'prawn/labels' #https://github.com/madriska/prawn-labels
require 'prawn-svg' #https://github.com/mogest/prawn-svg

id = 123456789012
Prawn::Labels.types = 'custom.yaml'

names = []
9.times do
  3.times do |i|
    names  << "#{id+i}"
  end
  id += 100
end

Prawn::Labels.generate("names.pdf", names, :type => "Avery18036") do |pdf, name|
  qrcode = RQRCode::QRCode.new("http://srv-1tee-moiron.ira.sch.gr:45537/asset/#{name}")
  svg = qrcode.as_svg
  IO.write("#{id}.svg", svg.to_s)

  pdf.svg IO.read("#{name}.svg"), at: [0,60], width: 50, height: 50
  pdf.svg IO.read("#{name}.svg"), at: [55,60], width: 50, height: 50
  pdf.svg IO.read("#{name}.svg"), at: [110,60], width: 50, height: 50
  pdf.draw_text name, at: [1,1], size: 7
  pdf.draw_text name, at: [55,1], size: 7
  pdf.draw_text name, at: [110,1], size: 7
end
