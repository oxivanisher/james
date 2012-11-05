<?php
ini_set("enable_dl","On");
include('../include/wiringpi.php');
include('../settings/settings.php');
include('../include/func.base.php');
include('../include/func.rasp.php');

#init
alert("RaspJames starting up.");
fancyInit();
$ATHOMECHECKLOOPS = 10000;
$atHomeCheckLoop = $ATHOMECHECKLOOPS;

#main loop
echo "looping...\n";
$run = true;
while ($run) {
	$atHomeCheckLoop++;

	foreach ($GLOBALS['BUTTONS'] as $i) {
		if (buttonCheck($i)) {
			echo alert("Button " . $i . " pressed.");
			$GLOBALS['POWERLEDBLINKNUM']++;
		}
	}

	foreach ($GLOBALS['SWITCHES'] as $i) {
		$result = switchCheck($i);

		if ($GLOBALS['switchState'][$i] == 1) {
			$str = "open";
		} else {
			$str = "closed";
		}

		if ($result) {
			echo alert ("Switch " . $i . " changed state to: " . $str . "\n");
		}
	}
		
	if ($atHomeCheckLoop > $ATHOMECHECKLOOPS) {
		$atHomeCheckLoop = 0;
		switchOff(3);
		blink(3, 2, 50000);
		$return = newEvent("is_at_home");
		if ($return == 0) {
			switchOn(3);
		}
	} else {
		$run = sleepLoop(7);
	}
}

?>
