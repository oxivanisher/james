#!/bin/bash

# based on:
# mac2vendor - lookup the OUI part of a MAC address in the IEEE registration
# Hessel Schut, hessel@isquared.nl, 2008-10-12

. /opt/james/settings/settings.sh

function get_mac_vendor {
        oui=$(sed -ne '{
		# strip all punctuation
		s/[\.:\-]//g

		# convert to uppercase
		s/[a-f]/\u&/g
						
		# rewrite to canonical format
		s/^\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\).*/\1-\2-\3/p
	} ' <<< $1)

	sed -n "/^${oui}/,/^$/p" ${MACVENDORFILE}
}

function nmap_scan {
    $NMAPPATH  -O $1
}
