<?php

class Teacher
{
	// property declaration
	public $day;
	public $name;
	public $first_hour;
	public $last_hour;
	// method declaration
	public function name() {
	echo $this->name;
	}
}

class Car
{
	// property declaration
	public $day;
	public $first_hour;
	public $last_hour;
	public $driver;
	public $leave_passengers;
	public $return_passengers;
	//////////////////////////////check and if $driver is  $car 's driver, if $psng is in $car leave and return passengers and if yes switch them
	public function switch_driver($driver, $psng, $car) { // returns true-false
		if ($car->driver->name==$driver){ // if car driver is the driver we are looking fo
			foreach ($car->leave_passengers as $leave_psng_key => $leave_psng) { 
				if($leave_psng->name==$psng){ //if passenger to switch is in leave pasngers
					$leave_psng_found=$leave_psng_key; 
					break;
				}
			}
			if (isset($leave_psng_found)){ // if found in leave psnger
				foreach ($car->return_passengers as $return_psng_key => $return_psng) { // check if also in return passengers of car
					if($return_psng->name==$psng){ //if passenger to switch is in return pasngers
						$return_psng_found=$return_psng_key; 
						break;
					}
				}
				if (isset($return_psng_found)){ // if also found in return psnger, bingo we can  make the switch
					$temp=$car->driver;
					$car->driver=$car->leave_passengers[$leave_psng_found];
					$car->leave_passengers[$leave_psng_found]=$temp;
					$car->return_passengers[$return_psng_found]=$temp;
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}

		}else{
			return false;
		}
	}
	/////////////////////////////////////// printout of car object
	public function printout() {
		$return_str="Car <br>Driver<br>:";
		$return_str+=$this->driver->name;
		$return_str+= "Passengers:<br>";
		echo '<HTML><head>
			<meta charset="UTF-8">
			</head> <body>';
		echo "<br> Dayno: ";
		echo $this->day;
		echo "<br> First hour: ";
		echo $this->first_hour;
		echo "<br><br>Oδηγός:";
		echo $this->driver->name;
		echo "<br>Επιβάτες αναχώρησης:<br> ";
		foreach ($this->leave_passengers as $leave_passenger){
			if (isset($leave_passenger->name)){
				$return_str += $leave_passenger->name + ", ";
				echo $leave_passenger->name;
				echo "<br>";
			}
		}
		echo "<br><br> Return hour: ";
		echo $this->last_hour;
		echo "<br>Επιβάτες επιστροφής: <br>";
		foreach ($this->return_passengers as $return_passenger){
			if (isset($return_passenger->name)){
				$return_str += $return_passenger->name + ", ";
				echo $return_passenger->name;
				echo "<br>";
			}
		}
		echo '</body></HTML>';
		$return_str += "<br>";
		return $return_str; 
    	}
	public function __construct() {
		//$driver = new Teacher();
		/*$passengers[0] = new Teacher();
		$passengers[1] = new Teacher();
		$passengers[2] = new Teacher();
		$passengers[3] = new Teacher();*/
    	}
	public function fill_car( $psng) { //puts teacher in empty pos, driver or leave pasenger
		if (!isset($this->driver))
		{
			$this->driver = new Teacher();
			$this->driver = $psng;
			$this->day = $this->driver->day;
			$this->first_hour = $this->driver->first_hour;
			$this->last_hour = $this->driver->last_hour;
			return true;
		}
		$last_key = count($this->leave_passengers);
		if ($last_key <4)
		{
			$this->leave_passengers[] = new Teacher();
			//$last_key = end($passengers);
			$this->leave_passengers[$last_key] = $psng;
			return true;
		}
		return false;
	}
	public function fill_car_for_return( $psng) { //puts teacher in empty pos, driver or leave pasenger
		if (!isset($this->driver))
		{
			$this->driver = new Teacher();
			$this->driver = $psng;
			$this->day = $this->driver->day;
			$this->first_hour = $this->driver->first_hour;
			return true;
		}
		$last_key = count($this->return_passengers);
		if ($last_key <4)
		{
			$this->return_passengers[] = new Teacher();
			//$last_key = end($passengers);
			$this->return_passengers[$last_key] = $psng;
			return true;
		}
		return false;
	}	
}

?>
