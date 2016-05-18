require 'spreadsheet'
require 'sinatra'
require 'haml'

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  redirect '/upload'
end

get '/upload' do
  haml :upload
end

post '/upload' do
  File.open('uploads/' + params['mine'][:filename], "w") do |f|
    f.write(params['mine'][:tempfile].read)
  end

  Spreadsheet.client_encoding = 'UTF-8'

  book = Spreadsheet.open "uploads/#{params['mine'][:filename]}"

  sheet1 = book.worksheet 0

  @STATE = 0

  @debug = false

  @ignoreMissingTeacher = true

  p params
  sem = params['semester']
  @checkA = (sem=="1")
  @checkB = (sem=="2")
  @checkC = (sem=="3")

  @missingStudents= {}
  @missingLessons = {}
  @missingTmimata = {}
  sheet1.each_with_index do |row,r|
    puts r if @debug
    column = 0
    row.each_with_index do |cell,i|
      cell = cell.strip unless (not cell) or (not cell.respond_to?(:strip))
      if @STATE == 0
        if cell =~ /Τμήμα/
          print "Βρήκα τμήμα " if @debug
          @tmima=row[8]
          puts @tmima if @debug
        elsif cell =~ /Μάθημα/
          print "Βρήκα μάθημα " if @debug
          @mathima=row[5]
          puts @mathima if @debug
        elsif cell =~ /Διδ.* Εκπ.*/
          print "Βρήκα και τους καθηγητές" if @debug
          @teacher=row[5]
          puts @teacher if @debug
        elsif cell =~ /Α\/Α/
          puts "Εδω ξεκινάνε οι μαθητές" if @debug
          raise "error1" unless @tmima
          raise "error2" unless @mathima
          if not @ignoreMissingTeacher 
            raise "error3" unless @teacher
          end
          raise "error4" unless @aTet
          raise "error4" unless @bTet
          raise "error4" unless @grapta

          @withDegree = 0
          @STATE=1
        elsif cell =~ /Α Τετ.*/
          @aTet = i
          puts "A tetramino at #{@aTet}" if @debug
        elsif cell =~ /Β Τετ.*/
          @bTet = i
          puts "B tetramino at #{@bTet}" if @debug
        elsif cell =~ /Γραπ.*/
          @grapta = i
          puts "grapta at #{@grapta}" if @debug
        end
      elsif @STATE==1
        puts "Δεν βρήκα το Α Τετράμηνο" unless @aTet
        puts "Δεν βρήκα το Β Τετράμηνο" unless @bTet
        puts "Δεν βρήκα τα γραπτα" unless @grapta
        if i==0 && (cell =~ // or not cell)
          @STATE=0
          puts "Εδώ τελειώνουν οι μαθητές" if @debug

          if @withDegree == 0
            if not @missingTmimata[@tmima] 
              @missingTmimata[@tmima] = []
            end
            @missingTmimata[@tmima] << @mathima unless @missingTmimata[@tmima].include? @mathima

            if not @missingLessons[@teacher] 
              @missingLessons[@teacher] = []
            end
            @missingLessons[@teacher] << @tmima unless @missingLessons[@teacher].include? @tmima
          end

          @tmima = @mathima = @teacher = nil
        elsif i>0
          next #we process the whole row from the first cell (cell 0)
        else
          if not @teacher and @ignoreMissingTeacher
            next
          end
          va = row[@aTet]
          vb = row[@bTet]
          vg = row[@grapta]
          if ( !va and @checkA) || ( !vb and @checkB) || ( !vg and @checkC)


            missingStudent = {}
            missingStudent[:am] = row[1]
            missingStudent[:onoma] = row[2]
            missingStudent[:epwnymo] = row[3]
            missingStudent[:patrwnymo] = row[4]
            missingStudent[:mitrwnymo] = row[5]
            missingStudent[:tmima] = @tmima
            missingStudent[:mathima] = @mathima
            missingStudent[:tetramino] = @tetramino
            missingStudent[:teacher] = @teacher
            
            fullname = "#{row[1]} #{row[2]} #{row[3]} #{row[4]} #{row[5]}"
            if not @missingStudents[fullname] 
              @missingStudents[fullname] = []
            end
            @missingStudents[fullname] << @mathima unless @missingStudents[fullname].include? @mathima

            puts "Λείπει ο βαθμός(#{va} #{vb} #{vg}) του #{row[1]}, #{row[2]}, #{row[3]} του #{@tmima} στο #{@mathima}" if @debug

          else
            @withDegree += 1
            puts "ολα καλα" if @debug
          end
        end
      end
    end
  end
  puts "Parsing finished" if @debug
  gets if @debug


  @missingStudents.each do |k, v|
    if v.size>0
      print k, ":"
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end

  puts "hit enter" if @debug
  gets if @debug

  @missingTmimata.each do |k, v|
    if v.size>0
      print k
      print " "
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end

  puts "hit enter" if @debug
  gets if @debug

  @missingLessons.each do |k,v|
    if v.size>0
      print k
      print " " 
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end

  haml :report

end#post

