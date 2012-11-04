<?php
ini_set("enable_dl","On");
include('../include/wiringpi.php');
include('../settings/settings.php');
include('../include/func.base.php');
include('../include/func.rasp.php');

#init
jamesAlert("RaspJames starting up.");
initLoop();
switchOn(0);
$ATHOMECHECKLOOPS = 5000;
$atHomeCheckLoop = 0;

#main loop
echo "looping...\n";
$run = true;
while ($run) {
	$atHomeCheckLoop++;

	for ($i=4; $i < 8; $i++) {
		if (buttonCheck($i)) {
			echo "here we go for button " . $i . "\n";
			jamesAlert("Button " . $i . " pressed.");
			$GLOBALS['POWERLEDBLINKNUM']++;
		}
	}
	
	if ($atHomeCheckLoop > $ATHOMECHECKLOOPS) {
		$atHomeCheckLoop = 0;
		blink(3, 1);
		ob_start();
		passthru("/opt/james/new_event.sh  is_at_home", $return);
		$content_grabbed=ob_get_contents();
		ob_end_clean();
		if (! $content_grabbed) {
			echo "away\n";
			switchOn(3);
		} else {
			echo "home\n";
		}
	}

	$run = sleepLoop();

}

?>
