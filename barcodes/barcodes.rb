require 'rqrcode'

#https://github.com/whomwah/rqrcode

qrcode = RQRCode::QRCode.new("http://srv-1tee-moiron.ira.sch.gr:45537/asset/1234567890")

svg = qrcode.as_svg
IO.write("g2-qrcode.svg", svg.to_s)

svg = qrcode.as_svg(module_size: 1)
IO.write("g2-qrcode.5.svg", svg.to_s)

svg = qrcode.as_svg(module_size: 0.1)
IO.write("g2-qrcode.10.svg", svg.to_s)

svg = qrcode.as_svg(module_size: 0.2)
IO.write("g2-qrcode.15.svg", svg.to_s)

