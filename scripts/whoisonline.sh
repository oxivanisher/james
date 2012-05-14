#!/bin/bash
source /opt/james/settings/settings.sh
$(which php) $BASEDIR/scripts/whoisonline.php "$@"
