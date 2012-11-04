<?php
ini_set("enable_dl","On");
include('../include/wiringpi.php');
include('../settings/settings.php');
include('../include/func.base.php');
include('../include/func.rasp.php');

#init
initLoop();
switchOn(0);
$ATHOMECHECKLOOPS = 10000;
$atHomeCheckLoop = 0;

#main loop
echo "looping...\n";
$run = true;
while ($run) {
	$atHomeCheckLoop++;

	for ($i=4; $i < 8; $i++) {
		if (buttonCheck($i)) {
			echo "here we go for button " . $i . "\n";
			alert("Button " . $i . " pressed.");
			$GLOBALS['POWERLEDBLINKNUM']++;
		}
	}
	
	if ($atHomeCheckLoop > $ATHOMECHECKLOOPS) {
		$atHomeCheckLoop = 0;
		blink(3, 1);
		$return = newEvent("is_at_home");
		if ($return == 0) {
			switchOn(3);
		}
	}

	$run = sleepLoop();
}

?>
