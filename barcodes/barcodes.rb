require 'rqrcode'

#https://github.com/whomwah/rqrcode

qrcode = RQRCode::QRCode.new("http://srv-1tee-moiron.ira.sch.gr:45537/asset/1234567890")

image = qrcode.as_png
svg = qrcode.as_svg
html = qrcode.as_html
string = qrcode.as_ansi
string = qrcode.to_s

IO.write("g2-qrcode.png", image.to_s)
IO.write("g2-qrcode.svg", svg.to_s)
IO.write("g2-qrcode.html", html.to_s)
IO.write("g2-qrcode.txt", string)
