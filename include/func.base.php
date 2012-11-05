<?php

function newEvent($event) {
	ob_start();
    passthru("/opt/james/new_event.sh " . $event, $return);
    $content_grabbed=ob_get_contents();
    ob_end_clean();

	return $content_grabbed;
}

function alert($message) {
	$modMessage = str_replace(" ", "\ ", $message);
	exec("/opt/james/new_event.sh alert \"" . $modMessage . "\" >/dev/null 2>&1 &");
    return "Alerted: $message\n";
}

?>
