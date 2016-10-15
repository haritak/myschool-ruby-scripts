require 'rmagick'

img = Magick::Image::read("test_input.jpg")[0]

new_img = img.black_threshold(220)
new_img = img.auto_level_channel

new_img.write("processed_output.tiff")
