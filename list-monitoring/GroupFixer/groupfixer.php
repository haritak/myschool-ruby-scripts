<?php
//error_reporting(E_ALL);
//ini_set('display_errors', 1);

require_once('PHPExcel.php');
require_once('PHPExcel/IOFactory.php');
require_once('groupfixer_classes.php');
const HOURS_PER_DAY = 7; 
const DAYS_PER_WEEK = 5;
const START_HOUR_GAP = 1;//gap when day hours start
//$psnger = new Teacher(); // create passenger object to store passenger data
$dromo_array = array();

//----ych
$handle = new SQLite3("whosin.db");

$sql = "SELECT * FROM teachers WHERE using_groups=1";
$ret=$handle->query($sql);
$teachers_included=array();
while($row = $ret->fetchArray(SQLITE3_ASSOC)) {
  $teachers_included[]= $row['timetables_name'];
}

//---ych

$_FILES["file"]["name"] = "EXCEL.xls";
$_FILES["file"]["tmp_name"] = "EXCEL.xls";
if (strlen($_FILES["file"]["name"])>4){
	if ($_FILES["file"]["error"] > 0)
	  {
	  echo "Error: " . $_FILES["file"]["error"] . "<br>";
	  }
	/*else
	  {
	  echo "Upload: " . $_FILES["file"]["name"] . "<br>";
	  echo "Type: " . $_FILES["file"]["type"] . "<br>";
	  echo "Size: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
	  echo "Stored in: " . $_FILES["file"]["tmp_name"];
		echo '<br>';
	  }*/

	//include 'PHPExcel/IOFactory.php';
	//$fileType = 'Excel5';
	//$fileName = $_FILES["file"]["name"];
	$fileName = $_FILES['file']['name'];
	if (substr($fileName, -3)=="xls"){
		// Read the file
		$objPHPExcel = PHPExcel_IOFactory::load($_FILES["file"]["tmp_name"]); //load uploaded tmp file 

		$highestRow = $objPHPExcel->setActiveSheetIndex(0)->getHighestRow();
		$highestColumn = $objPHPExcel->setActiveSheetIndex(0)->getHighestColumn();
		$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn); // e.g 5
		$objWorksheet = $objPHPExcel->getActiveSheet();
		//print_r($_FILES["file"]);
		$passenger_names = array();
		
		for ($row = 1; $row <= $highestRow; ++$row) {
			$cell=trim($objWorksheet->getCellByColumnAndRow(0, $row)->getValue()) ;
			if ($cell>""){
				$name = $cell;
        //-->ych
        $name = str_replace("/","_",$name);
        /* if this is a new name, insert it! */
        $sql = "SELECT * from teachers WHERE timetables_name='" . $name . "'";
        $ret = $handle->query($sql);
        if ($ret->fetchArray(SQLITE3_ASSOC) == FALSE) {
          /* this is a new name, go on and insert it to whosin.db */
          $sql = "INSERT INTO teachers VALUES('".$name."',0)";
          $op = $handle->prepare($sql);
          $op->execute();
        }


        if (!in_array($name, $teachers_included)) {
          continue;
        }
        //<---ych
        //echo "\n";
        //echo $name . "\n";
        //echo "\n";
				$name_array=explode(" ",$cell);
				if (preg_match('/[0-9]+/', $name_array[0])){ //IF THERE IS NUMBER in first substring to catch ΠΕ13..
					$name = "";
					$count = count($name_array);
					for ($i = 1; $i < $count; $i++) {    //reject first part ΠΕ19
					    $name = $name . $name_array[$i]." ";
					}
					$name = trim($name);

				}
				array_push($passenger_names, $name);
				//echo $name . '<br>';
		
				for ($day = 0; $day <= DAYS_PER_WEEK-1; ++$day) { //per day
					$first_hour = 0;
					$last_hour = 0;
			
					for ($hour_col = 1+START_HOUR_GAP; $hour_col <= 1+HOURS_PER_DAY+START_HOUR_GAP; ++$hour_col) { //per hour
						$col = $day*(START_HOUR_GAP+HOURS_PER_DAY)+$hour_col; //1 is where the name is+ day*hours/day+ hour
						$lesson = $objWorksheet->getCellByColumnAndRow($col, $row)->getValue();  //get cell value
						if ($lesson > ""){
							if ($first_hour==0)
								$first_hour=$hour_col-START_HOUR_GAP;
							$last_hour=$hour_col-START_HOUR_GAP;
						}
						else{
							foreach($objWorksheet->getMergeCells() as $range) { //find merged cells for last hour because they are empty
								 if ($objWorksheet->getCellByColumnAndRow($col, $row)->isInRange($range)) {
									$last_hour=$hour_col-START_HOUR_GAP;
									break;
								}
							}
						}
					}
					if ($first_hour>0){
						//echo "day ".$day. ": ";
						//echo  $first_hour."&nbsp;-".$last_hour."&nbsp;";
						$psnger = new Teacher();
						$psnger->name = $name;
						$psnger->day = $day;
						$psnger->first_hour = $first_hour;
						$psnger->last_hour = $last_hour;
						//echo  $psnger->first_hour."&nbsp;-".$psnger->last_hour."&nbsp;";
						$dromo_array[$day][] = $psnger;
						unset($psnger);

					}
				}
			}
		}

		unset($objPHPExcel);
		//print_r($dromo_array);
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		for ($day = 0; $day <= DAYS_PER_WEEK-1; ++$day)//foreach ($dromo_array as $day_dromos) 
		{	
			$day_teachers = $dromo_array[$day]; //table with day passengers
			$day_teachers_temp = $day_teachers; //temporary table
	
			//echo "<br>";    fill the leave passengers and driver////////////////////////////////////////////////////
			$cars_no = ceil(count($day_teachers)/5); //cars no per day
			for ($car = 0 ; $car < $cars_no; ++$car){
				$cars[$day][$car] = new Car();
			}
			//$cnt = 0;	
			while (sizeof($day_teachers_temp)>0) // move from teachers from table to cars
			{	//echo "sizeof temp: " + sizeof($day_teachers_temp);
				//print_r($day_teachers_temp);
				//echo "<br> table size ";
				//echo sizeof($day_teachers_temp);
				//echo "<br>";
				//$cnt+=1;
				//if ($cnt > 50){break;}

		
		
				for ($teacher_no = 0; $teacher_no < sizeof($day_teachers_temp)-1; ++$teacher_no) //find min leave hour teacher to insert
				{	
					if (($day_teachers_temp[$teacher_no]->first_hour< $day_teachers_temp[$teacher_no+1]->first_hour)or (($day_teachers_temp[$teacher_no]->first_hour== $day_teachers_temp[$teacher_no+1]->first_hour)and ($day_teachers_temp[$teacher_no]->last_hour< $day_teachers_temp[$teacher_no+1]->last_hour))) //move min leave and return hour last
					{
						$temp = $day_teachers_temp[$teacher_no];
						$day_teachers_temp[$teacher_no] = $day_teachers_temp[$teacher_no+1];
						$day_teachers_temp[$teacher_no+1] = $temp;
					}	 
				}
				for ($car = 0 ; $car < $cars_no; ++$car){ // add leave passengers to cars //add min leave hour teacher to car and remve him from table
					if ($cars[$day][$car]->fill_car( $day_teachers_temp[sizeof($day_teachers_temp)-1]))
					{	//$temp = $day_teachers_temp[$leave_psng_pos];
						unset($day_teachers_temp[sizeof($day_teachers_temp)-1]); //unset last element
						break; // break the loop if inserted
					}
				}
			}
			// fill the return passengers/////////////////////////////////////////////////////////////
			$day_teachers_temp = $day_teachers; //temporary table 
		
			while (sizeof($day_teachers_temp)>0) // move from teachers from table to cars return passengers
			{	
				for ($teacher_no = 0; $teacher_no < sizeof($day_teachers_temp)-1; ++$teacher_no) //find min return hour teacher to insert
				{	
					if ($day_teachers_temp[$teacher_no]->last_hour< $day_teachers_temp[$teacher_no+1]->last_hour) //move min leave hour last
					{
						$temp = $day_teachers_temp[$teacher_no];
						$day_teachers_temp[$teacher_no] = $day_teachers_temp[$teacher_no+1];
						$day_teachers_temp[$teacher_no+1] = $temp;
					}	 
				}
				$is_driver = false;
				for ($car = 0 ; $car < $cars_no; ++$car){ // find if min leave hour teacher is driver
					if ($day_teachers_temp[sizeof($day_teachers_temp)-1]===$cars[$day][$car]->driver){
						$is_driver = true;
						unset($day_teachers_temp[sizeof($day_teachers_temp)-1]); //remove teacher, already placed as driver
					}
				}
				if(!$is_driver){ // if not driver place him
					for ($car = 0 ; $car < $cars_no; ++$car){ // add leave passengers to cars //add min leave hour teacher to car and remve him from table
						if ($cars[$day][$car]->fill_car_for_return( $day_teachers_temp[sizeof($day_teachers_temp)-1]))
						{	//$temp = $day_teachers_temp[$leave_psng_pos];
							unset($day_teachers_temp[sizeof($day_teachers_temp)-1]); //unset last element
							break; // break the loop if inserted
						}
					}
				}
			}
		} 
		///////////////////////////////////////////////////dromologia output in HTML//////////////////////////////////
		/*for ($day = 0; $day <= DAYS_PER_WEEK-1; ++$day)//foreach ($dromo_array as $day_dromos) 
		{
			foreach($cars[$day] as $car){
			$car->printout();
			//echo $car->driver->name;
			//echo "<br>";
			}
		echo "<br>";
		}
		*/
		
		///////////////////////////////////////////create new temporary excel with names & hours//////////////////////
		$objPHPExcel_come_leave_hours = new PHPExcel();

		// Set document properties
		$objPHPExcel_come_leave_hours->getProperties()->setCreator("glemon")
									 ->setLastModifiedBy("Lemonakis George")
									 ->setTitle("Teachers come and leave hours")
									 ->setSubject("Office 2003 XLS Test Document")
									 ->setDescription("Teachers come and leave hours, generated using groupfixer application.")
									 ->setKeywords("office 2003 openxml php")
									 ->setCategory("App result file");


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//fill excel file come-leave hours
		$objPHPExcel_come_leave_hours->setActiveSheetIndex(0);
		
		$line_no = 0;
		$activeSheet = $objPHPExcel_come_leave_hours->getActiveSheet();
		$day_names = array('0' =>'Δευτέρα', '1' =>'Τρίτη', '2' =>'Τετάρτη', '3' =>'Πέμπτη', '4' =>'Παρασκευή', '5' =>'Σάββατο', '6' =>'Κυριακή');
		$activeSheet->getColumnDimension('A')->setWidth(3);
		$activeSheet->getColumnDimension('B')->setWidth(3);
		$activeSheet->getColumnDimension('C')->setWidth(15);
		$activeSheet->getColumnDimension('D')->setWidth(15);
		$activeSheet->getColumnDimension('E')->setWidth(15);
		$activeSheet->getColumnDimension('F')->setWidth(15);
		$activeSheet->getColumnDimension('G')->setWidth(15);
		
        $activeSheet->mergeCells('A1:H1');
        $activeSheet->getStyle('A1')->getFont()->setBold(true);
        $activeSheet->setCellValueByColumnAndRow(0, 1, 'Εβδομαδιαίο πρόγραμμα δρομολογίων καθηγητών');
		for ($day = 0; $day <= DAYS_PER_WEEK-1; ++$day)//foreach ($dromo_array as $day_dromos) 
		{
			$line_no += 2;
			$activeSheet->mergeCells('A'.$line_no.':H'.$line_no);
			$activeSheet->getStyle('A'.$line_no)->getFont()->setSize(12);
			$activeSheet->getStyle('A'.$line_no)->getFill()//set return passenger background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFFFFFFF');
			$activeSheet->getStyle('A'.$line_no)->getFont()->setBold(true);
			$activeSheet->setCellValueByColumnAndRow(0, $line_no, $day_names[$day]);
			$line_no += 1;
			
			$activeSheet->setCellValueByColumnAndRow(0, $line_no, '1η ωρα');
			$activeSheet->setCellValueByColumnAndRow(1, $line_no, 'Τελ. ώρα');
			$activeSheet->setCellValueByColumnAndRow(2, $line_no, 'Οδηγός');
			$activeSheet->mergeCells('D'.$line_no.':E'.$line_no);
			$activeSheet->setCellValueByColumnAndRow(3, $line_no, 'Επιβάτες αναχώρησης');
			$activeSheet->mergeCells('F'.$line_no.':G'.$line_no);
			$activeSheet->setCellValueByColumnAndRow(5, $line_no, 'Επιβάτες επιστροφής');
			$activeSheet->setCellValueByColumnAndRow(7, $line_no, 'Αναχώρ.');
			$line_no -= 1;
			
			foreach($cars[$day] as $car){
				$line_no += 2;
				$activeSheet->getStyle('A'.$line_no.':M'.($line_no+1))->getFont()->setSize(8);
				if ( $line_no/2 & 1 ) {//even odd lines set different color
					/*$activeSheet->getStyle('D'.$line_no.':G'.$line_no)->getFill() //set leave passenger background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFF0F8FF');*/
					$activeSheet->getStyle('A'.$line_no.':H'.($line_no+1))->getFill()//set return passenger background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFFAEBD7');
					/*$activeSheet->getStyle('C'.$line_no)->getFill()//set driver background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFFAEBD7');*/
				} 
				$activeSheet->setCellValueByColumnAndRow(0, $line_no, $car->first_hour);
				$activeSheet->setCellValueByColumnAndRow(1, $line_no, $car->last_hour);
				$activeSheet->setCellValueByColumnAndRow(2, $line_no, $car->driver->name.'_'.$car->driver->first_hour.'-'.$car->driver->last_hour);
				$activeSheet->mergeCells('A'.$line_no.':A'.($line_no+1));
				$activeSheet->mergeCells('B'.$line_no.':B'.($line_no+1));
				$activeSheet->mergeCells('C'.$line_no.':C'.($line_no+1));
				$counter = 0;				
				foreach($car->leave_passengers as $leave_passenger){ //set leave passengers
					if ($counter < 2){
						$activeSheet->setCellValueByColumnAndRow(3+$counter, $line_no, $leave_passenger->name.'_'.$leave_passenger->first_hour.'-'.$leave_passenger->last_hour);
					}else{
						$activeSheet->setCellValueByColumnAndRow(3+$counter-2, $line_no+1, $leave_passenger->name.'_'.$leave_passenger->first_hour.'-'.$leave_passenger->last_hour);
					}
					$counter += 1;
				}
				$counter = 0;
				foreach($car->return_passengers as $return_passenger){ //set leave passengers
					if ($counter < 2){
						$activeSheet->setCellValueByColumnAndRow(5+$counter, $line_no, $return_passenger->name.'_'.$return_passenger->first_hour.'-'.$return_passenger->last_hour);
					}else{
						$activeSheet->setCellValueByColumnAndRow(5+$counter-2, $line_no+1, $return_passenger->name.'_'.$return_passenger->first_hour.'-'.$return_passenger->last_hour);
					}
					$counter += 1;
				}			
			}
		}
		$activeSheet->setTitle(date("d-m-y"));
		// set borders
		$styleArray = array(
		  'borders' => array(
		    'allborders' => array(
		      'style' => PHPExcel_Style_Border::BORDER_THIN
		    )
		  )
		);

		$activeSheet->getStyle('A1:H'.($line_no+1))->applyFromArray($styleArray);
		unset($styleArray);
		///////////////////////////add statistics area
        $highestRow = $activeSheet->getHighestRow();
        $stats_startrow = $highestRow+2;
		$activeSheet->setCellValueByColumnAndRow(2, $stats_startrow, 'Στατιστικά (για να δουλεύουν σωστά πρέπει οι regular expressions (κανονικές εκφράσεις) να είναι ενεργοποιημένες στο λογιστικό φύλλο (στο Libre Office Calc: Εργαλεία/επιλογές-LibreOffice Calc-Υπολογισμός-Ενεργοποίηση κανονικών εκφράσεων σε τύπους))');
		$activeSheet->setCellValueByColumnAndRow(2, $stats_startrow+1, 'Οδηγός');
		$activeSheet->setCellValueByColumnAndRow(3, $stats_startrow+1, 'Οδήγηση εβδομάδας');
		$activeSheet->setCellValueByColumnAndRow(4, $stats_startrow+1, 'Χρήση εβδομάδας');
		$activeSheet->setCellValueByColumnAndRow(5, $stats_startrow+1, 'Οδήγηση προηγούμενων εβδομάδων');
		$activeSheet->setCellValueByColumnAndRow(6, $stats_startrow+1, 'Χρήση προηγούμενων εβδομάδων');
		$activeSheet->setCellValueByColumnAndRow(7, $stats_startrow+1, 'Οδηγηση συνολικά');
		$activeSheet->setCellValueByColumnAndRow(8, $stats_startrow+1, 'Χρήση συνολικά');
		$activeSheet->setCellValueByColumnAndRow(9, $stats_startrow+1, 'Χρήση/οδήγηση');
		
        //set header bgcolor for stats
        $activeSheet->getStyle('D'.($stats_startrow+1).':E'.($stats_startrow+1))->getFill()//set return passenger background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFFAEBD7');
         $activeSheet->getStyle('H'.($stats_startrow+1).':I'.($stats_startrow+1))->getFill()//set return passenger background
						->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
						->getStartColor()->setARGB('FFFAEBD7');
                        
		/*$activeSheet->getColumnDimension('K')->setWidth(4);
		$activeSheet->getColumnDimension('L')->setWidth(4);
		$activeSheet->getColumnDimension('M')->setWidth(4);
		$activeSheet->getColumnDimension('N')->setWidth(4);
		$activeSheet->getColumnDimension('O')->setWidth(4);
		$activeSheet->getColumnDimension('P')->setWidth(4);
		$activeSheet->getColumnDimension('Q')->setWidth(5);		*/
		sort($passenger_names);
		$row = $stats_startrow+2;
		//$highestRow = $activeSheet->getHighestRow();
        //put names and stats
		foreach($passenger_names as $passenger_name){
			$activeSheet->setCellValueByColumnAndRow(2, $row, $passenger_name.'.*');
			$activeSheet->setCellValueByColumnAndRow(3, $row, '=COUNTIF(C$1:C$'.$highestRow.', C'.$row.')'); //Οδήγηση εβδομάδας
			$activeSheet->setCellValueByColumnAndRow(4, $row, '=COUNTIF(D$1:G$'.$highestRow.', C'.$row.')/2');//Χρήση εβδομάδας
			$activeSheet->setCellValueByColumnAndRow(7, $row, '=D'.$row.'+F'.$row); //Οδηγ. σύνολ
			$activeSheet->setCellValueByColumnAndRow(8, $row, '=E'.$row.'+G'.$row); //Χρήση σύνολ
			$activeSheet->setCellValueByColumnAndRow(9, $row, '=I'.$row.'/H'.$row);//Χρήση/οδηγ
			$activeSheet->getStyleByColumnAndRow(9, $row)->getNumberFormat()->setFormatCode('0.00'); 
			//=COUNTIF(C$1:C$45;J5) 
			//$activeSheet->setCellValueExplicit('K' . $row, '=COUNTIF(C$1:C$'.$highestRow.';J'.$row.')');
			$row += 1;
		}
		$activeSheet->getStyle('C'.($stats_startrow+1).':J'.$row)->getFont()->setSize(8);
		
		// Redirect output to a client’s web browser (Excel5)
		header('Content-Type: application/vnd.ms-excel');
		header('Content-Disposition: attachment;filename="dromologia.xls"');
		header('Cache-Control: max-age=0');
		// If you're serving to IE 9, then the following may be needed
		header('Cache-Control: max-age=1');

		// If you're serving to IE over SSL, then the following may be needed
		header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
		header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
		header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
		header ('Pragma: public'); // HTTP/1.0


		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel_come_leave_hours, 'Excel5');
		//$objWriter->save('/usr/local/etc/dromo.xls');
		$objWriter->save('php://output');
		exit;

		


		/*echo '<table border =1>' . "\n";
			for ($row = 1; $row <= $highestRow; ++$row) {
				echo '<tr>' . "\n";
				for ($col = 0; $col <= $highestColumnIndex; ++$col) {
					echo '<td>' . $objWorksheet->getCellByColumnAndRow($col, $row)->getValue() .
					'</td>' . "\n";
				}
				echo '</tr>' . "\n";
			}
			echo '</table>' . "\n";
		*/
	}else{
		echo "Filetype must be Excel (.xls).";
	}
}
else{
	echo "No file selected.";
}
?> 



