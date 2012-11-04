<?php
ini_set("enable_dl","On");
include('../include/wiringpi.php');
include('../settings/settings.inc.php');
include('../include/functions.inc.php');

#init
alert("RaspJames starting up.");
initLoop();
switchOn(0);

#main loop
echo "looping...\n";
$run = true;
while ($run) {

	for ($i=4; $i < 8; $i++) {
		if (buttonCheck($i)) {
			echo "here we go for button " . $i . "\n";
			alert("Button " . $i . " pressed.");
		}
	}

	$run = quitCheck();

}

?>
