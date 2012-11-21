<?php
#helper functions
function fancyInit($leds = array(), $buttons = array(), $switches = array()) {

	if (count($leds) == 0) $leds = $GLOBALS['LEDS'];
	if (count($buttons) == 0) $buttons = $GLOBALS['BUTTONS'];
	if (count($switches) == 0) $switches = $GLOBALS['SWITCHES'];
	asort($leds);
	asort($buttons);
	asort($switches);

	initLoop($leds, $buttons);

	echo "Starting RaspJames Bot:\n";
	echo "\tInitializing leds: ";
	foreach ($leds as $i) {
		echo $i . " ";
		blink($i, 3, 50000); }
	echo "\n";

	echo "\tInitializing buttons: ";
	foreach ($buttons as $i) {
		echo $i . " ";
		switchOn($i);
		$GLOBALS['buttonLock'][$i] = 0;
		$GLOBALS['quitCounter'][$i] = 0;
	}
	echo "\n";

	echo "\tInitializing switches: ";
	foreach ($switches as $i) {
		echo $i . " ";
		switchOn($i);
		$GLOBALS['switchState'][$i] = 1;
	}
	echo "\n";

	$GLOBALS['powerBlinkCount'] = 0;
	$GLOBALS['POWERLEDBLINKINT'] = 5;
	$GLOBALS['POWERLEDBLINKNUM'] = 1;

	register_shutdown_function('quitLoop');
	echo "Initialization done. Beginning to loop.\n";
}
function initLoop($leds = array(), $buttons = array(), $switches = array()) {
	wiringPiSetup();

	if (count($leds) == 0) $leds = $GLOBALS['LEDS'];
	if (count($buttons) == 0) $buttons = $GLOBALS['BUTTONS'];
	if (count($switches) == 0) $switches = $GLOBALS['SWITCHES'];
	asort($leds);
	asort($buttons);
	asort($switches);

	echo "Resetting all lines...\n";
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
function switchCheck($pin) {
	$actualState = wiringpi::digitalRead($pin);
	$ret = false;
	if ($actualState != $GLOBALS['switchState'][$pin]) {
		$GLOBALS['switchState'][$pin] = $actualState;
		$ret = true;
	}
	if ($actualState) {
		switchOff(2);
	} else {
		switchOn(2);
	}
	return $ret;
}
function buttonCheck($pin, $reset = 0) {
    if ($reset == 0) $reset = $GLOBALS['BUTTONRESET'];
    if (wiringpi::digitalRead($pin)) {
        if (($GLOBALS['buttonLock'][$pin] + $reset) < time() AND $GLOBALS['buttonLock'][$pin] != 0) {
            switchOff(1);
            $GLOBALS['quitCounter'][$pin] = 0;
            $GLOBALS['buttonLock'][$pin] = 0;
            echo "BUTTON " . $pin . ": lock reset\n";
        }
    } else {
        switchOn(1);
        $GLOBALS['quitCounter'][$pin]++;
        if (($GLOBALS['buttonLock'][$pin] + $reset) < time()) {
            $GLOBALS['buttonLock'][$pin] = time();
            echo "BUTTON " . $pin . ": pressed and locked for " . $reset . " seconds.\n";
            return true;
        }
    }
    return false;
}
function sleepLoop($id) {
	if (! isset($GLOBALS['quitCounter'][$id])) $GLOBALS['quitCounter'][$id] = 0;
	$counter = $GLOBALS['quitCounter'][$id];
	if ($counter >= ($GLOBALS['QUITTIME'] * round(1000000 / $GLOBALS['LOOPUSLEEP']))) {
		alert("BUTTON " . $id . ": pressed for " . $GLOBALS['QUITTIME'] . " seconds. exiting...\n");
		blink(3, 5, 50000);
		# this is our exit signal. rasp james will exit now
		return false;
	}

	$tmpUsleep = $GLOBALS['LOOPUSLEEP'];
	$maxBlinkCount = round(($GLOBALS['POWERLEDBLINKINT'] * 400000) / ($GLOBALS['POWERLEDBLINKNUM'] * 40000 * 2), 0, PHP_ROUND_HALF_DOWN);
	
	if ($GLOBALS['POWERLEDBLINKNUM'] > $maxBlinkCount) {
		$GLOBALS['POWERLEDBLINKNUM'] = $maxBlinkCount;
	}
	if ($GLOBALS['powerBlinkCount'] >= $GLOBALS['PWRLEDLOOPBLINK']) {
		$GLOBALS['powerBlinkCount'] = 0;
		blink(0, $GLOBALS['POWERLEDBLINKNUM'], 40000);
		$tmpUsleep = $tmpUsleep - ($GLOBALS['POWERLEDBLINKNUM'] * 2 * 40000);
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
