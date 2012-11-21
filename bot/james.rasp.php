<?php
ini_set("enable_dl","On");
include('../include/wiringpi.php');
include('../settings/settings.php');
include('../include/func.base.php');
include('../include/func.rasp.php');

#init
alert("RaspJames starting up.");
fancyInit();
$atHomeCheckLoop = $GLOBALS['ATHOMECHECKLOOPS'];
$initTime = microtime(true);
$timeBetweenHomeChecks = $initTime;
$timeBetweenMainLoops = $initTime;
$timeBetweenMainLoopsCount = 0;

#main loop
$run = true;
while ($run) {
	$atHomeCheckLoop++;

	#is our button pressed?
	if (buttonCheck(4)) {
			#for each button press, blink 1 additional time (just for fun :)
			$GLOBALS['POWERLEDBLINKNUM']++;
			#echo alert ("Toggle  Radio");
			#round(microtime(true) - $initTime) . " seconds.");
			system("/usr/bin/mpc -q toggle");
	}

	foreach ($GLOBALS['SWITCHES'] as $i) {
		$result = switchCheck($i);

		if ($GLOBALS['switchState'][$i] == 1) {
			$str = "open";
		} else {
			$str = "closed";
		}

		if ($result) {
			echo alert ("SWITCH " . $i . ": Changed state to: " . $str . "\n");
		}
	}
		
	if ($atHomeCheckLoop > $GLOBALS['ATHOMECHECKLOOPS']) {
		echo "At home check time interval: " . round((microtime(true) - $timeBetweenHomeChecks), 2) . " seconds.\n";
		$timeBetweenHomeChecks = microtime(true);
		$atHomeCheckLoop = 0;
		switchOff(3);
		blink(3, 2, 50000);
		$return = newEvent("is_at_home");
		if ($return == 0) {
			switchOn(3);
		}
	} else {
		$timeBetweenMainLoopsCount++;
		if ($timeBetweenMainLoopsCount >= 10000) {
		#	echo "it took " . (microtime(true) - $timeBetweenMainLoops) . " seconds for 10000 main loops.\n";
			echo "Main loop performance: ~" . round((10000 / (microtime(true) - $timeBetweenMainLoops)), 2) . " loops per second\n";
			$timeBetweenMainLoopsCount = 0;
			$timeBetweenMainLoops = microtime(true);
		}
		#echo "main loop time interval: " . (microtime(true) - $timeBetweenMainLoops) . " seconds.\n";
		$run = sleepLoop(4);
	}
}

?>
