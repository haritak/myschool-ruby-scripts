require 'spreadsheet'

require 'pry'

Spreadsheet.client_encoding = 'UTF-8'

book = Spreadsheet.open './seleniumDownloads/rptList.xls'

sheet1 = book.worksheet 0

@STATE = 0

@debug = false

@checkA = false
@checkB = true
@checkC = false


missingStudents= {}
missingLessons = {}
missingTmimata = {}
missingLessons = {}
sheet1.each do |row|
  column = 0
  row.each_with_index do |cell,i|
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
        @STATE=1
      elsif cell =~ /Α Τετ.*/
        @aTet = i
      elsif cell =~ /Β Τετ.*/
        @bTet = i
      elsif cell =~ /Γραπ.*/
        @grapta = i
      end
    elsif @STATE==1
      puts "Δεν βρήκα το Α Τετράμηνο" unless @aTet
      puts "Δεν βρήκα το Β Τετράμηνο" unless @bTet
      puts "Δεν βρήκα τα γραπτα" unless @grapta
      if i>0 
        next 
      end
      if i==0 && cell =~ //
        @STATE=0
        puts "Εδώ τελειώνουν οι μαθητές" if @debug
      else
        va = row[@aTet]
        vb = row[@bTet]
        vg = row[@grapta]
        if (not va and @checkA) ||
           (not vb and @checkB) ||
           (not vg and @grapta)
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
          missingStudents[fullname] << missingStudent


          if not missingTmimata[@tmima] 
            missingTmimata[@tmima] = []
          end
          missingTmimata[@tmima] << missingStudent

          if not missingLessons[@teacher] 
            missingLessons[@teacher] = []
          end
          missingLessons[@teacher] << missingStudent
          puts "Για το πρώτο τρίμηνο Λείπει ο βαθμός του #{row[1]}, #{row[2]}, #{row[3]} του #{@tmima} στο #{@mathima}" if @debug
        else
          puts "ολα καλα" if @debug
        end
      end
    end
  end

end

  #missingStudents.each do |k, v|
    #puts k
    #puts v.size
  #end

  missingTmimata.each do |k, v|
    puts k if v.size>2
  end

  if false
  missingLessons.each do |k,v|
    print k
    print " " 
    print v.size
    puts k if v.size>1
  end
  end


