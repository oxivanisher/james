#!/usr/bin/php
<?php
ini_set("enable_dl","On");
include('/opt/james/include/wiringpi.php');
include('/opt/james/settings/settings.php');
include('/opt/james/include/func.base.php');
include('/opt/james/include/func.rasp.php');

switch ($GLOBALS['argv'][1]) {
	case "ledTest":
		$leds = $GLOBALS['LEDS'];
		$buttons = $GLOBALS['BUTTONS'];
		asort($leds);
		asort($buttons);

		echo "initializing leds: ";
		foreach ($leds as $i) {
			$oldState = wiringpi::digitalRead($i);
			echo $i . " ";
			blink($i, 2, 50000);
			if ($oldState) switchOn($i);
		}
		echo "done\n";

	break;;

	case "status":
		echo "RaspBerryPi Status Output:\n";
		echo "_LED_\n";
		asort($GLOBALS['LEDS']);
		foreach ($GLOBALS['LEDS'] as $led) {
			if (wiringpi::digitalRead($led) == 1) {
				$str = "on";
			} else {
				$str = "off";
			}
			echo $led . ": " .$str . "\n";
		}

		echo "_Button_\n";
		asort($GLOBALS['BUTTONS']);
		foreach ($GLOBALS['BUTTONS'] as $button) {
			if (wiringpi::digitalRead($button) == 1) {
				$str = "high";
			} else {
				$str = "low";
			}

			echo $button . ": " . $str . "\n";
		}
	break;;

	case "switchOn":
		if ($GLOBALS['argv'][2]) {
			switchOn($GLOBALS['argv'][2]);
			echo "done";
		} else {
			echo "please specify pin";
		}
	break;;

	case "switchOff":
		if ($GLOBALS['argv'][2]) {
			switchOff($GLOBALS['argv'][2]);
			echo "done";
		} else {
			echo "please specify pin";
		}
	break;;

	default:
		echo "commands: ledTest, status, switchOn, switchOff";
}
?>
