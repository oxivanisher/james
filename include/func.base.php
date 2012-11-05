<?php

function newEvent($event) {
	ob_start();
    passthru("/opt/james/new_event.sh " . $event, $return);
    $content_grabbed=ob_get_contents();
    ob_end_clean();

	return $content_grabbed;
}

function alert($message) {
	$message = str_replace(" ", "\ ", $message);
	newEvent("alert \"" . $message . "\" >/dev/null 2>&1 &");
    return $message;
}

?>
