require 'rqrcode' #https://github.com/whomwah/rqrcode
require 'prawn/labels' #https://github.com/madriska/prawn-labels
require 'prawn-svg' #https://github.com/mogest/prawn-svg

Prawn::Labels.types = 'avery.yaml'

names = ["Yannis Charitakis"]*48

Prawn::Labels.generate("ych.pdf", names, :type => "AveryL6009") do |pdf, name|
  qrcode = RQRCode::QRCode.new("http://ych.gr")
  svg = qrcode.as_svg
  IO.write("ych.svg", svg.to_s)

  pdf.svg IO.read("ych.svg"), at: [70,60], width: 50, height: 50
  pdf.draw_text "Charitakis", at: [10,50], size: 10
  pdf.draw_text "Yannis", at: [10,39], size: 10
  pdf.draw_text "http://ych.gr", at: [10,19], size: 10
end
