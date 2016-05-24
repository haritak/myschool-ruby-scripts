require 'spreadsheet'
require 'sinatra'
require 'haml'
require 'chartkick'
require 'yaml'


set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  redirect '/report'
end

get '/upload' do
  haml :upload
end

get '/report' do
  haml :report_index
end

get '/report/:class/:semester' do
  @taksi = params[:class]
  @semester = params[:semester]

  @taksi = 'a' if @taksi == 'Α'
  @taksi = 'b' if @taksi == 'Β'
  @taksi = 'c' if @taksi == 'Γ'

  filename = "#{@taksi}.#{@semester}.yaml"

  begin
    @modtime = File.mtime( filename )
    @storage = YAML::load_file filename

    @taksi =@storage[:taksi]
    @semester =@storage[:semester]
    @missingStudents =@storage[:missingStudents]
    @missingTmimata =@storage[:missingTmimata]
    @missingLessons =@storage[:missingLessons]
    @katanomiVathmwn =@storage[:katanomiVathmwn]
    @katanomiVathmwnEid =@storage[:katanomiVathmwnEid]
    @katanomiVathmwnGP =@storage[:katanomiVathmwnGP]
    @perTeacherAvg =@storage[:perTeacherAvg]
    @perTeacherStdDev =@storage[:perTeacherStdDev]
    @perMathimaAvg =@storage[:perMathimaAvg]
    @gradesPerSex =@storage[:gradesPerSex]
    @perStudentAvg =@storage[:perStudentAvg]
    @sortedPerStudentAvg =@storage[:sortedPerStudentAvg]
    @top10Students =@storage[:top10Students]

    haml :report
  rescue => e
    "Δεν υπάρχουν δεδομένα"
  end
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
  @semester = sem
  @checkA = (sem=="1")
  @checkB = (sem=="2")
  @checkC = (sem=="3")

  @missingStudents= {}
  @missingLessons = {}
  @missingTmimata = {}

  @katanomiVathmwn = {}
  @katanomiVathmwnGP = {}
  @katanomiVathmwnEid = {}

  @perTeacherSum = {}
  @perTeacherCount = {}
  @perTeacherMarks = {}

  @perStudentSum = {}
  @perStudentCount = {}

  @perMathimaSum = {}
  @perMathimaCount = {}

  @girlsSum = 0
  @girlsCount = 0
  @boysSum = 0
  @boysCount = 0
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
        elsif cell =~ /Τάξη/
          @taksi = row[8]
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

          fullname = "#{row[1]} #{row[2]} #{row[3]} #{row[4]} #{row[5]}"
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
            
            if not @missingStudents[fullname] 
              @missingStudents[fullname] = []
            end
            @missingStudents[fullname] << @mathima unless @missingStudents[fullname].include? @mathima

            puts "Λείπει ο βαθμός(#{va} #{vb} #{vg}) του #{row[1]}, #{row[2]}, #{row[3]} του #{@tmima} στο #{@mathima}" if @debug

          else
            @withDegree += 1

            v = va if @checkA
            v = vb if @checkB
            v = vg if @checkC

            if @katanomiVathmwn[v.to_i]
              @katanomiVathmwn[v.to_i] += 1
            else
              @katanomiVathmwn[v.to_i] = 1
            end

            targetArr = @katanomiVathmwnEid
            if @mathima =~ /^ΓΠ.*/
              targetArr = @katanomiVathmwnGP
            end
            if targetArr[v.to_i]
              targetArr[v.to_i] += 1
            else
              targetArr[v.to_i] = 1
            end

            if not @perTeacherCount[@teacher] 
              @perTeacherCount[@teacher] = 1
              @perTeacherSum[@teacher] = v.to_i
              @perTeacherMarks[@teacher] = [v.to_i]
            else
              @perTeacherCount[@teacher] += 1
              @perTeacherSum[@teacher] += v.to_i
              @perTeacherMarks[@teacher] << v.to_i
            end

            if not @perMathimaCount[@mathima] 
              @perMathimaCount[@mathima] = 1
              @perMathimaSum[@mathima] = v.to_i
            else
              @perMathimaCount[@mathima] += 1
              @perMathimaSum[@mathima] += v.to_i
            end

            if row[3] =~ /.*Σ$/
              @boysCount += 1
              @boysSum += v.to_i
            else
              @girlsCount += 1
              @girlsSum += v.to_i
            end

            if not @perStudentCount[fullname]
              @perStudentCount[fullname] = 1
              @perStudentSum[fullname] = v.to_i
            else
              @perStudentCount[fullname] += 1
              @perStudentSum[fullname] += v.to_i
            end
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

  arrays = [@katanomiVathmwn, @katanomiVathmwnGP, @katanomiVathmwnEid]

  arrays.each do |arr|
    20.times do |k|
      arr[k] = 0 unless arr[k]
      v = arr[k]
      print k,":(",v,")"
      puts
    end
  end

  @perTeacherAvg = {}
  @perTeacherCount.each do |k,v|
    @perTeacherAvg[k] = @perTeacherSum[k]/ v
    print k, ":", @perTeacherAvg[k]
    puts
  end

  @perTeacherStdDev = {}
  @perTeacherMarks.each do |k, v|
    @perTeacherStdDev[k] = 0
    v.each do |mark|
      @perTeacherStdDev[k] += (mark - @perTeacherAvg[k])**2
    end
    @perTeacherStdDev[k] = Math.sqrt( @perTeacherStdDev[k] ) / @perTeacherCount[k]
  end


  @perMathimaAvg = {}
  @perMathimaCount.each do |k,v|
    @perMathimaAvg[k] = @perMathimaSum[k] / v
  end

  sorted = @perMathimaAvg.sort_by {|k,v| v }
  sorted.each do |k,v|
    print k, ":", v
    puts
  end

  @gradesPerSex = {}
  @gradesPerSex["Boys"] = @boysSum/@boysCount
  @gradesPerSex["Girls"] = @girlsSum/@girlsCount

  @gradesPerSex.each do |k,v|
    print k,v
  end

  @perStudentAvg = {}
  @perStudentCount.each do |k,v|
    @perStudentAvg[k] = @perStudentSum[k]/v
  end

  @sortedPerStudentAvg = @perStudentAvg.sort_by{ |k,v| v }

  @top10Students = @sortedPerStudentAvg.last(10).reverse.to_h

  @taksi = 'a' if @taksi == 'Α'
  @taksi = 'b' if @taksi == 'Β'
  @taksi = 'c' if @taksi == 'Γ'

  @storage={}
  @storage[:taksi] = @taksi
  @storage[:semester] = @semester
  @storage[:missingStudents] = @missingStudents
  @storage[:missingTmimata] = @missingTmimata
  @storage[:missingLessons] = @missingLessons
  @storage[:katanomiVathmwn] = @katanomiVathmwn
  @storage[:katanomiVathmwnEid] = @katanomiVathmwnEid
  @storage[:katanomiVathmwnGP] = @katanomiVathmwnGP
  @storage[:perTeacherAvg] = @perTeacherAvg
  @storage[:perTeacherStdDev] = @perTeacherStdDev
  @storage[:perMathimaAvg] = @perMathimaAvg
  @storage[:gradesPerSex] = @gradesPerSex
  @storage[:perStudentAvg] = @perStudentAvg
  @storage[:sortedPerStudentAvg] = @sortedPerStudentAvg
  @storage[:top10Students] = @top10Students


  filename = "#{@taksi}.#{@semester}.yaml"
  File.open(filename, "w") do |f|
    f.write @storage.to_yaml
  end

  #haml :report
  puts "/report/#{@taksi}/#{@semester}"
  redirect "/report/#{@taksi}/#{@semester}"

end#post

