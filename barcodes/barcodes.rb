#https://github.com/whomwah/rqrcode
require 'rqrcode'

#https://github.com/toretore/barby
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'


encoded_string=[ "http://srv-1tee-moiron.ira.sch.gr:45537/asset/1234567890",
"2016101825A3",
"1210,1212",
"YYYYMMDDCIDAMM01AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM02AMM35"]

encoded_string.each_with_index do |s,i|
  qrcode = RQRCode::QRCode.new( s )
  barcode = Barby::Code128B.new(s.encode("US-ASCII"))
  File.open("barcode.#{i}.png", 'wb'){|f| f.write barcode.to_png(height:20)}

  svg = qrcode.as_svg
  IO.write("qr.#{i}.svg", svg.to_s)

  svg = qrcode.as_svg(module_size: 1)
  IO.write("qr.#{i}.5.svg", svg.to_s)

  svg = qrcode.as_svg(module_size: 0.1)
  IO.write("qr.#{i}.10.svg", svg.to_s)

  svg = qrcode.as_svg(module_size: 0.2)
  IO.write("qr.#{i}.15.svg", svg.to_s)
end
