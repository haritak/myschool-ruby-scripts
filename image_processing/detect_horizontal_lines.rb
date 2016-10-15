require 'chunky_png'

def isHorizontalLine(img, y)
  x=0
  x+=1 while (x<img.width and img[x,y]!=ChunkyPNG::Color::BLACK)
  return false if x>img.width/2

  #puts "Found first not black pixel at #{x} of line #{y}"
  firstBlackPixel = x


  #detect slopiness
  startingAtLine=y
  goUp=false
  goDown=false
  while x<img.width
    if img[x,y] == ChunkyPNG::Color::BLACK
      x+=1
    elsif img[x,y+1] == ChunkyPNG::Color::BLACK
      goDown=true
      #puts "Line brakes at pixel #{x} and I will go down"
      break
    elsif img[x,y-1] == ChunkyPNG::Color::BLACK
      goUp=true
      #puts "Line brakes at pixel #{x} and I will go up"
      break
    else
      break
    end
  end

  return true if x-firstBlackPixel>(3*img.width/4)

  y=y+1 if goDown
  y=y-1 if goUp

  while x<img.width
    if img[x,y]==ChunkyPNG::Color::BLACK
      x+=1
    else 
      y=y+1 if goDown
      y=y-1 if goUp
      break if (y-startingAtLine).abs>20
      break if img[x,y]!=ChunkyPNG::Color::BLACK
    end
  end

  puts "Line #{startingAtLine} was followed until #{x} on line #{y}"

  return true if x-firstBlackPixel>(3*img.width/4)

  return false

end


input_file = "bw.png"
output_file = "horizontalLines.png"

puts "loading image #{input_file}"
src = ChunkyPNG::Image.from_file(input_file)
puts src.metadata
puts src.width
puts src.height

trg = ChunkyPNG::Image.new(src.width,src.height)

puts "Detecting horizonal lines"
countHorizontalLines = 0

y=0
while y<src.height-10 do
  if isHorizontalLine(src, y)
    countHorizontalLines+=1
    x=0
    begin
      trg[x,y] = ChunkyPNG::Color.rgba(0, 255,0, 255)
      x+=1
    end while x<trg.width

    9.times do
      x=0
      y+=1
      begin
        trg[x,y] = src[x,y]
        x+=1
      end while x<trg.width
    end

  else
    x=0
    begin
      trg[x,y] = src[x,y]
      x+=1
    end while x<trg.width
  end
  if y%100==0 then puts y end
  y+=1
end

puts ("Found #{countHorizontalLines} horizontal lines")

#second pass
puts "Saving to #{output_file}"
trg.save(output_file)



