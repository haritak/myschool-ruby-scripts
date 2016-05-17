require 'spreadsheet'

require 'pry'

Spreadsheet.client_encoding = 'UTF-8'

book = Spreadsheet.open './seleniumDownloads/rptList.xls'

sheet1 = book.worksheet 0

@STATE = 0

@debug = false

@ignoreMissingTeacher = true

@checkA = false
@checkB = true
@checkC = false

missingStudents= {}
missingLessons = {}
missingTmimata = {}
missingLessons = {}
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

        @missingCounter = 0
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

          @missingCounter += 1

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
          if not missingStudents[fullname] 
            missingStudents[fullname] = []
          end
          missingStudents[fullname] << @mathima unless missingStudents[fullname].include? @mathima

          puts "Λείπει ο βαθμός(#{va} #{vb} #{vg}) του #{row[1]}, #{row[2]}, #{row[3]} του #{@tmima} στο #{@mathima}" if @debug

          next if @missingCounter < 5

          if not missingTmimata[@tmima] 
            missingTmimata[@tmima] = []
          end
          missingTmimata[@tmima] << @mathima unless missingTmimata[@tmima].include? @mathima

          if not missingLessons[@teacher] 
            missingLessons[@teacher] = []
          end
          missingLessons[@teacher] << @tmima unless missingLessons[@teacher].include? @tmima

        else
          puts "ολα καλα" if @debug
        end
      end
    end
  end
end
puts "Parsing finished"
gets

  missingStudents.each do |k, v|
    if v.size>0
      print k, ":"
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end

  puts "hit enter"
  gets

  missingTmimata.each do |k, v|
    if v.size>0
      print k
      print " "
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end

  puts "hit enter"
  gets

  missingLessons.each do |k,v|
    if v.size>0
      print k
      print " " 
      puts v.size
      v.each do |l|
        puts " #{l}"
      end
    end
  end


