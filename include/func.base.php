<?php

function newEvent($event) {
	ob_start();
    passthru("/opt/james/new_event.sh " . $event, $return);
    $content_grabbed=ob_get_contents();
    ob_end_clean();

	return $content_grabbed;
}

function alert($message) {
    newEvent("alert \'" . $message . "\'");
    return $message;
}

?>
