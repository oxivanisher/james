#!/usr/bin/php
<?php

#require_once("../settings/settings.php");

# Settings for PHP scripts
$GLOBALS['basedir'] = "/opt/james/";
date_default_timezone_set('Europe/Zurich');


# Transmission Settings
$GLOBALS['xbuser'] = "xbmc";
$GLOBALS['xbpass'] = "";
$GLOBALS['xbhost'] = "xbmc.thunderbluff.ch";
$GLOBALS['xbport'] = 9090;
$GLOBALS['xburl']  = "/jsonrpc";


#VideoLibrary.Scan

# helper functions
function returnStatus ($status) {
	switch ($status) {
		case 0:
			return "Stopped";
		break;

		case 4:
			return "Downloading";
		break;

		default:
			return "Unknown";
	}
}

# system functions
/*
function checkSession () {
	if (empty ($GLOBALS['trsid'])) {
		echo "checking session\n";
		$ch = curl_init();
		# application/x-www-form-urlencoded.
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_USERPWD, $GLOBALS['xbuser'] . ":" . $GLOBALS['xbpass']);
		curl_setopt($ch, CURLOPT_URL, "http://" . $GLOBALS['xbhost'] . ":" . $GLOBALS['xbport'] . $GLOBALS['xburl'] );
		curl_setopt($ch, CURLOPT_HEADER, true);
		curl_setopt($ch, CURLOPT_NOBODY, true);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	
		$header = curl_exec($ch);
		$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		curl_close($ch);
			echo "header:\n";
			print_r($header);
		preg_match("/^X-Transmission-Session-Id: (.*)$/m", $header, $return);

		$GLOBALS['trsid'] = $return[1];	
	} else {
		die ("Could not connect to server: " . "http://" . $GLOBALS['trhost'] . ":" . $GLOBALS['trport'] . $GLOBALS['trurl']);
	}
}
*/

function query ($command, $arguments = null) {
	if ($arguments) {
		$data_string = json_encode(array("jsonrpc" => "2.0", "id" => 1, "method" => $command, "params" => $arguments));
	} else {
		$data_string = json_encode(array("jsonrpc" => "2.0", "id" => 1, "method" => $command));
	}
#	$payload = array('X-Transmission-Session-Id: ' . $GLOBALS['trsid'], 'Content-Length: ' . strlen($data_string));
	$payload = array('Content-Length: ' . strlen($data_string));


#	if ($fp = @fsockopen($GLOBALS['xbhost'], $GLOBALS['xbport'], $fsockErrNo, $fsockErrStr, 5)) {
	if ($fp = @fsockopen($GLOBALS['xbhost'], $GLOBALS['xbport'])) {
        $rawRequest = 'POST ' . $GLOBALS['xburl'] . ' HTTP/1.0' . PHP_EOL
                      . 'Content-type: text/json;charset=utf-8' . PHP_EOL
#                      . 'X-Transmission-Session-Id: ' . $GLOBALS['trsid'] . PHP_EOL
                      . 'Authorization: Basic ' . base64_encode($GLOBALS['xbuser'] . ':' . $GLOBALS['xbpass']) . PHP_EOL
                      . 'Content-Length: ' . strlen($data_string) . PHP_EOL . PHP_EOL
                      . $data_string;
        fwrite($fp, $rawRequest);
        $response = stream_get_contents($fp);
        fclose($fp);
	
		$data = json_decode($response);

		if (! empty($data->error)) {
			echo "An error occured. Request was:\n";
			echo $rawRequest;
			echo "\nServer says:\n";
			die ((string) $data->error->message . " (" . (string) $data->error->code . ")\n");
		} else {
			return $data;
		}
	} else {
		die ("socket could not be opened\n");
	}
}


#Here we go!
#echo "Connecting to http://" . $GLOBALS['trhost'] . ":" . $GLOBALS['trport'] . $GLOBALS['trurl'] . "\n";
#checkSession();
#echo "X-Transmission-Session-Id: " . $GLOBALS['trsid'] . "\n";

if (empty($argv[1])) $argv[1] = null;

switch ($argv[1]) {
	case "update":
		$data = query ("VideoLibrary.Scan");
		echo (string) $data->result . "\n";
	break;

	case "notify":
		$data = query ("JSONRPC.NotifyAll", array("sender" => "xbmc.php", "message" => "test"));
		print_r($data);
		echo (string) $data->result . "\n";
	break;

	default:
		echo "Commands are: update\n";
	break;
}

?>
