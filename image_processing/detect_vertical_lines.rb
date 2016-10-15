require 'chunky_png'

def isVerticalLine(img, x)
  y=0
  y+=1 while (y<img.height and img[x,y]!=ChunkyPNG::Color::BLACK)
  return false if y>img.height/2

  firstBlackPixel = y

  #detect slopiness
  startingAtColumn=x
  goLeft=false
  goRight=false
  while y<img.height
    if img[x,y] == ChunkyPNG::Color::BLACK
      y+=1
    elsif img[x+1,y] == ChunkyPNG::Color::BLACK
      goRight=true
      break
    elsif img[x-1,y] == ChunkyPNG::Color::BLACK
      goLeft=true
      break
    else
      break
    end
  end

  return true if y-firstBlackPixel>(3*img.height/4)

  x=x+1 if goRight
  x=x-1 if goLeft

  while y<img.height
    if img[x,y]==ChunkyPNG::Color::BLACK
      y+=1
    else 
      x=x+1 if goRight
      x=x-1 if goLeft
      break if (x-startingAtColumn).abs>20
      break if img[x,y]!=ChunkyPNG::Color::BLACK
    end
  end

  if y>100
    puts "Column #{startingAtColumn} was followed until #{x} on line #{y}"
  end

  return true if y-firstBlackPixel>(3*img.height/4)

  return false

end


input_file = "bw.png"
output_file = "verticalLines.png"

puts "loading image #{input_file}"
src = ChunkyPNG::Image.from_file(input_file)
puts src.metadata
puts src.width
puts src.height

trg = ChunkyPNG::Image.new(src.width,src.height)

puts "Detecting vertical lines"
countVerticalLines = 0

x=0
while x<src.width-10 do
  if isVerticalLine(src, x)
    countVerticalLines+=1
    y=0
    begin
      trg[x,y] = ChunkyPNG::Color.rgba(0, 255,0, 255)
      y+=1
    end while y<trg.height

    9.times do
      y=0
      x+=1
      begin
        trg[x,y] = src[x,y]
        y+=1
      end while y<trg.height
    end

  else
    y=0
    begin
      trg[x,y] = src[x,y]
      y+=1
    end while y<trg.height
  end
  if x%100==0 then puts x end
  x+=1
end

puts ("Found #{countVerticalLines} vertical lines")

#second pass
puts "Saving to #{output_file}"
trg.save(output_file)



