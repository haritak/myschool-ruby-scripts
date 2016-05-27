# encoding: UTF-8

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'pdf/label'

p = PDFLabelPage.new("Avery  7160") #sold by e-shop : http://www.e-shop.gr/etiketes-avery-adress-label-635-x-381mm-250-fylla-5250-tem-p-ANA.AVE01016

p.draw_boxes(false, true)

p.save_as("sample.pdf")
