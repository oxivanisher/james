#!/usr/bin/php
<?php

$GLOBALS['truser'] = "admin";
$GLOBALS['trpass'] = "kickass";
$GLOBALS['trhost'] = "xbmc.thunderbluff.ch";
$GLOBALS['trport'] = 9091;
$GLOBALS['trurl']  = "/transmission/rpc";
$GLOBALS['trsid']  = null;

# helper functions
function formatBytes($bytes, $precision = 2) { 
    $units = array('B', 'KB', 'MB', 'GB', 'TB'); 

    $bytes = max($bytes, 0); 
    $pow = floor(($bytes ? log($bytes) : 0) / log(1024)); 
    $pow = min($pow, count($units) - 1); 

    // Uncomment one of the following alternatives
    $bytes /= pow(1024, $pow);
    // $bytes /= (1 << (10 * $pow)); 

    return round($bytes, $precision) . ' ' . $units[$pow]; 
}

# system functions
function checkSession () {
	if (empty ($GLOBALS['trsid'])) {
		$ch = curl_init();
		# application/x-www-form-urlencoded.
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_USERPWD, $GLOBALS['truser'] . ":" . $GLOBALS['trpass']);
		curl_setopt($ch, CURLOPT_URL, "http://" . $GLOBALS['trhost'] . ":" . $GLOBALS['trport'] . $GLOBALS['trurl'] );
		curl_setopt($ch, CURLOPT_HEADER, true);
		curl_setopt($ch, CURLOPT_NOBODY, true);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	
		$header = curl_exec($ch);
		$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		curl_close($ch);

		preg_match("/^X-Transmission-Session-Id: (.*)$/m", $header, $return);

		$GLOBALS['trsid'] = $return[1];	
	} else {
		die ("Could not connect to server: " . "http://" . $GLOBALS['trhost'] . ":" . $GLOBALS['trport'] . $GLOBALS['trurl']);
	}
}

function query ($command, $arguments = null) {
#	if ($arguments) {
		$data_string = json_encode(array("method" => $command, "arguments" => $arguments));
#	} else {
#		$data_string = json_encode(array("method" => $command));
#	}
	$payload = array('X-Transmission-Session-Id: ' . $GLOBALS['trsid'], 'Content-Length: ' . strlen($data_string));

	if ($fp = @fsockopen('localhost', 9091, $fsockErrNo, $fsockErrStr, $fsockTimeout)) {
        $rawRequest = 'POST /transmission/rpc HTTP/1.0' . PHP_EOL
                      . 'Content-type: text/json;charset=utf-8' . PHP_EOL
                      . 'X-Transmission-Session-Id: ' . $GLOBALS['trsid'] . PHP_EOL
                      . 'Authorization: Basic ' . base64_encode($GLOBALS['truser'] . ':' . $GLOBALS['trpass']) . PHP_EOL
                      . 'Content-Length: ' . strlen($data_string) . PHP_EOL . PHP_EOL
                      . $data_string;
        fwrite($fp, $rawRequest);
        $response = stream_get_contents($fp);
        fclose($fp);
	
		$http = explode("\r\n\r\n", $response);
		$data = json_decode($http[1]);

		if ((string)$data->result == "success") {
			return $data->arguments;
		} else {
			die ((string) $data->result . "\n");
		}
	} else {
		die ("socket could not be opened\n");
	}
}


#Here we go!
#echo "Connecting to http://" . $GLOBALS['trhost'] . ":" . $GLOBALS['trport'] . $GLOBALS['trurl'] . "\n";
checkSession();
#echo "X-Transmission-Session-Id: " . $GLOBALS['trsid'] . "\n";

if (empty($argv[1])) $argv[1] = null;

switch ($argv[1]) {
	case "stop":
		if (isset($argv[2])) {
			$data = query("torrent-stop", array("ids" => $argv[2]));
			echo "Success!\n";
		} else {
			$data = query("torrent-stop");
			die("Success on all Torrents!\n");
		}
	break;

	case "start":
		if (isset($argv[2])) {
			$data = query("torrent-start", array("ids" => $argv[2]));
			echo "Success!\n";
		} else {
			$data = query("torrent-start");
			die("Success on all Torrents!\n");
		}
	break;

	case "remove":
		if (isset($argv[2])) {
			$ids = explode(",", $argv[2]);
			if (empty($ids)) {
				$data = query("torrent-remove");
			} elseif (count($ids) == 1) {
				$data = query("torrent-remove", array("ids" => (int) $argv[2]));
			} else {
				$data = query("torrent-remove", array("ids" => array($ids)));
			}
			echo "Success!\n";
		} else {
			die("Please add id(s)!\n");
		}
	break;

	case "stats":
		$data = query ("session-stats");
		print_r($data);
	break;

	case "add":
		if (isset($argv[2])) {
			$data = query("torrent-add", array("filename" => $argv[2]));
			echo "Success!\n";
		} else {
			die("Please add a URL or MAGNET link.\n");
		}
	break;

	case "list":
		$return = query ("torrent-get",array("fields" => (array("name", "id", "error", "errorString", "leftUntilDone", "percentDone", "status", "totalSize", "uploadRatio"))));
		foreach ($return as $torrents) {
			foreach ($torrents as $torrent) {
				echo (string) $torrent->id . " " . ((string) $torrent->percentDone * 100)  . "% " . (string) $torrent->name . "\n";
				if ($torrent->error > 0) echo " ERROR: " . (string) $torrent->errorString . "\n";
				echo "  " . formatBytes((string) $torrent->leftUntilDone) . " of " . formatBytes((string) $torrent->totalSize) . " left";
				echo "; Status: " . (string) $torrent->status . "; Ul: " . ((string) $torrent->uploadRatio * 100) . "%\n";
			}
		}
		
		$data = query ("session-stats");
		echo "A:" . (string) $data->activeTorrentCount;
		echo " P:" . (string) $data->pausedTorrentCount;
		echo " T:" . (string) $data->torrentCount . " | ";
		echo "Down: " . formatBytes((string) $data->downloadSpeed) . "/s; Up: " . formatBytes((string) $data->uploadSpeed) . "/s\n";
	break;

	default:
		echo "Please specify: list, add, start, stop, stats, remove\n";
}

?>
