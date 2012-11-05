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
$timeBetweenHomeChecks = microtime(true);
$timeBetweenMainLoops = microtime(true);
$initTime = microtime(true);
$timeBetweenMainLoopsCount = 0;

#main loop
echo "looping...\n";
$run = true;
while ($run) {
	$atHomeCheckLoop++;

	#is our button pressed?
	if (buttonCheck(7)) {
			#for each button press, blink 1 additional time
			$GLOBALS['POWERLEDBLINKNUM']++;
			echo alert ("James Rasp is running since " . round(microtime(true) - $initTime) . " seconds.");
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
		
	if ($atHomeCheckLoop > $GLOBALS['ATHOMECHECKLOOPS']) {
		echo "at home check time interval: " . (microtime(true) - $timeBetweenHomeChecks) . " seconds.\n";
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
			echo "it took " . (microtime(true) - $timeBetweenMainLoops) . " seconds for 10000 main loops.\n";
			$timeBetweenMainLoopsCount = 0;
			$timeBetweenMainLoops = microtime(true);
		}
		#echo "main loop time interval: " . (microtime(true) - $timeBetweenMainLoops) . " seconds.\n";
		$run = sleepLoop(7);
	}
}

?>
