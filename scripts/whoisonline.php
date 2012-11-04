#!/usr/bin/php
<?php

require_once("/opt/james/settings/settings.php");
require_once("/opt/james/settings/func.base.php");


#Who is online
#Settings

$dbfile = $GLOBALS['basedir'] . "data/whoisonline.csv";

#Helper functions

function load_csv($file) {
    $row = 0;
    $return = false;
    if (($handle = fopen($file, "r")) !== FALSE) {
        while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
            $row++;
            for ($c = 0; $c < count($data); $c++)
                $return[$row][$c] = $data[$c];
        }
        fclose($handle);
    }
    return $return;
}

function save_csv($file, $line) {
    $fp = fopen($file, 'a');
    fwrite($fp, $line);
    fclose($fp);
}

### here we go ###
# Load out database
$db = null;
foreach (load_csv($dbfile) as $entry) {
    $mac = strtolower($entry[1]);
    if ((!empty($entry[4])) && (!empty($mac))) {
        $db[$mac][0] = $entry[0]; #type
        $db[$mac][1] = $entry[2]; #comment
        $db[$mac][2] = $entry[3]; #hidden
        $db[$mac][3] = $entry[4]; #owner
        $db[$mac][4] = "0.0.0.0"; #online/ip
        $db[$mac][5] = $mac;      #MAC
    }
}

# scan for devices
$onlinemacs = null;
$onlinemacs = newEvent("arp_scan");
foreach ($onlinemacs as $onlinemacsLine) {
    $out = split("	", $onlinemacsLine);
    if (count($out) > 1) {
        if (filter_var($out[0], FILTER_VALIDATE_IP)) {
            $tmpmac = strtolower($out[1]);
            if (empty($db[$tmpmac][0])) {
                # this is a unknown mac. save it
                $db[$tmpmac][0] = "unknown";           #type
                $db[$tmpmac][1] = date('Y-m-d H:i:s'); #comment
                $db[$tmpmac][2] = 0;                   #hidden
                $db[$tmpmac][3] = "nobody";            #owner
                $db[$tmpmac][4] = $out[0];             #online/ip
                save_csv($dbfile, $db[$tmpmac][0] . ";" . $tmpmac . ";" . $db[$tmpmac][1] . ";" . $db[$tmpmac][2] . ";" . $db[$tmpmac][3] . "\n");

                # notify about and scan that thing
                alert("Unknown host detected!");
            } else {
                # this already known device is online
                $db[$tmpmac][4] = $out[0]; #online/ip
            }
        }
    }
}

#are we running in cli or web mode?
if (!isset($_REQUEST["mode"]))
    $_REQUEST["mode"] = "web";
if (PHP_SAPI === 'cli') {
    foreach ($db as $line) {
        if (($line[2] == false) || (isset($argv[1])))
            if ($line[4] != "0.0.0.0") {
                $tmpIndex = explode(".", $line[4]);
                $tmpArray[$tmpIndex[3]]["type"] = $line[0];
                $tmpArray[$tmpIndex[3]]["comment"] = $line[1];
                $tmpArray[$tmpIndex[3]]["owner"] = $line[3];
                $tmpArray[$tmpIndex[3]]["ip"] = $line[4];
                $tmpArray[$tmpIndex[3]]["mac"] = $line;
            }
    }
    //print_r($tmpArray);
    if (isset($tmpArray)) {
        ksort($tmpArray);
        foreach ($tmpArray as $key => $data) {
            echo $data["ip"] . "\t" . $data["owner"] . "\t" . $data["comment"] . " (" . $data["type"] . ")\n";
        }
    }
} elseif ($_REQUEST["mode"] == "csv") {
    foreach ($db as $line) {
        echo $line[0] . ";" . $line[1] . ";" . $line[2] . ";" . $line[3] . ";" . $line[4] . ";" . $line[5] . ";\n";
    }
} else {
    echo "<html><head><title>whoisonline</title></head><body><pre>";
    echo "<table>";
    echo "<tr>";
    echo "<th>Type</th><th>Comment</th><th>Hidden</th><th>Owner</th><th>Online / IP</th><th>MAC</th>";
    echo "</tr>";
    foreach ($db as $line) {
        echo "<tr>";
        echo "<td>" . $line[0] . "</td><td>" . $line[1] . "</td><td>" . $line[2] . "</td><td>" . $line[3] . "</td><td>" . $line[4] . "</td><td>" . $line[5] . "</td>";
        echo "</tr>";
    }
    echo "</table>";
    echo "</pre></body></html>";
}
?>
