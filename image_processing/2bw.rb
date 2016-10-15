require 'chunky_png'

input_file = "ScannedDocument.png"
output_file = "bw.png"

puts "loading image #{input_file}"
src = ChunkyPNG::Image.from_file(input_file)
puts src.metadata
puts src.width
puts src.height

trg = ChunkyPNG::Image.new(src.width,src.height)

puts "First pass, make it black and white"
y=0
while y<src.height do
  x=0
  while x<src.width do
    colorSum = ChunkyPNG::Color.r(src[x,y]) +
      ChunkyPNG::Color.g(src[x,y]) +
      ChunkyPNG::Color.b(src[x,y])

    if colorSum>3*100 
      trg[x,y] = ChunkyPNG::Color::WHITE
    else
      trg[x,y] = ChunkyPNG::Color::BLACK
    end

    x+=1
  end

  if y%1000==0 then puts y end
  y+=1
end

puts "Saving to #{output_file}"
trg.save(output_file)



