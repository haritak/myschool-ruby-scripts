require 'barby/barcode/code_39'
require 'barby/outputter/ascii_outputter'
require 'barby/outputter/png_outputter'
require 'barby/outputter/pdfwriter_outputter'

barcode_data = "12345"
barcode39 = Barby::Code39.new(barcode_data) # Default value is false
barcode39_ext = Barby::Code39.new(barcode_data, true)

#puts barcode39_ext.to_ascii

# And if you want it PNG style
File.open('barcode39.png', 'w'){|f| f.write barcode39.to_png }
File.open('barcode39_ext.png', 'w'){|f| f.write barcode39_ext.to_png }

require 'rqrcode'

qrcode = RQRCode::QRCode.new("http://srv-1tee-moiron.ira.sch.gr/ktimatologio/1234567890")
image = qrcode.as_png
svg = qrcode.as_svg
html = qrcode.as_html
string = qrcode.as_ansi
string = qrcode.to_s

IO.write("g2-qrcode.png", image.to_s)

