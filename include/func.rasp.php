<?php
#helper functions
function fancyInit($leds = array(), $buttons = array()) {
	if (count($leds) == 0) $leds = $GLOBALS['LEDS'];
	if (count($buttons) == 0) $buttons = $GLOBALS['BUTTONS'];
	asort($leds);
	asort($buttons);

	initLoop($leds, $buttons);

	echo "initializing leds: ";
	foreach ($leds as $i) {
		echo $i . " ";
		blink($i, 2, 50000); }
	echo "\n";

	echo "initializing buttons: ";
	foreach ($buttons as $i) {
		echo $i . " ";
		switchOn($i);
		$GLOBALS['buttonLock'][$i] = 0;
		$GLOBALS['quitCounter'][$i] = 0;
	}
	echo "\n";

	$GLOBALS['powerBlinkCount'] = 0;
	$GLOBALS['POWERLEDBLINKINT'] = 5;
	$GLOBALS['POWERLEDBLINKNUM'] = 1;

	register_shutdown_function('quitLoop');
}
function initLoop($leds = array(), $buttons = array()) {
	wiringPiSetup();

	if (count($leds) == 0) $leds = $GLOBALS['LEDS'];
	if (count($buttons) == 0) $buttons = $GLOBALS['BUTTONS'];
	asort($leds);
	asort($buttons);

	echo "resetting all lines...\n";
	for ($i=0; $i < 8; $i++) {
		switchOff($i);
		wiringpi::pinMode($i, 1);
	}
}
function switchOn($pin) {
	wiringpi::digitalWrite($pin, 1);
}
function switchOff($pin) {
	wiringpi::digitalWrite($pin, 0);
}
function blink($pin, $amount = 1, $duration = 100000) {
	for ($i = 0; $i < $amount; $i++) {
		switchOn($pin);
		usleep($duration);
		switchOff($pin);
		usleep($duration);
	}
}
function buttonCheck($pin, $reset = 0) {
	if ($reset == 0) $reset = $GLOBALS['BUTTONRESET'];
	if (wiringpi::digitalRead($pin)) {
		if (($GLOBALS['buttonLock'][$pin] + $reset) < time() AND $GLOBALS['buttonLock'][$pin] != 0) {
			switchOff(1);
			$GLOBALS['quitCounter'][$pin] = 0;
			$GLOBALS['buttonLock'][$pin] = 0;
			echo "button lock reset on pin " . $pin . "\n";
		}
	} else {
		switchOn(1);
		$GLOBALS['quitCounter'][$pin]++;
		if (($GLOBALS['buttonLock'][$pin] + $reset) < time()) {
			$GLOBALS['buttonLock'][$pin] = time();
			echo "button " . $pin . " pressed and locked for " . $reset . " seconds.\n";
			return true;
		}
	}
	return false;
}
function sleepLoop() {
	foreach ($GLOBALS['quitCounter'] as $counter) {
		if ($counter >= ($GLOBALS['QUITTIME'] * round(1000000 / $GLOBALS['LOOPUSLEEP']))) {
			echo "pressed a button for longer than " . $GLOBALS['QUITTIME'] . " secs. exiting...\n";
			blink(3, 2);
			return false;
		}
	}

	$maxBlinkCount = round(($GLOBALS['POWERLEDBLINKINT'] * 1000000) / ($GLOBALS['POWERLEDBLINKNUM'] * 100000 * 2), 0, PHP_ROUND_HALF_DOWN);
	$tmpUsleep = $GLOBALS['LOOPUSLEEP'];

	if ($GLOBALS['POWERLEDBLINKNUM'] > $maxBlinkCount) {
	#	echo "max blinks while sleep loop reached (" . $GLOBALS['POWERLEDBLINKNUM'] . "/" . $maxBlinkCount . ")\n";
		$GLOBALS['POWERLEDBLINKNUM'] = $maxBlinkCount;
	}
	if ($GLOBALS['powerBlinkCount'] >= ($GLOBALS['POWERLEDBLINKINT'] * round(1000000 / $GLOBALS['LOOPUSLEEP']))) {
		$GLOBALS['powerBlinkCount'] = 0;
	#	echo "blinking " . $GLOBALS['POWERLEDBLINKNUM'] . "/" . $maxBlinkCount . " times\n";
		blink(0, $GLOBALS['POWERLEDBLINKNUM'], 100000);
		$tmpUsleep = $tmpUsleep - ($GLOBALS['POWERLEDBLINKNUM'] * 2 * 100000);
	}
	$GLOBALS['powerBlinkCount']++;

	if ($tmpUsleep > 0) usleep ($tmpUsleep);
	return true;
}
function quitLoop($leds = array(), $buttons = array()) {
	if (count($leds) == 0) $leds = $GLOBALS['LEDS'];
	if (count($buttons) == 0) $buttons = $GLOBALS['BUTTONS'];
	foreach ($buttons as $i) switchOff($i);
	foreach ($leds as $i) switchOff($i);
	alert("RaspJames shutting down.");
}
?>
