#!/bin/bash

source /opt/james/settings/settings.sh

/usr/bin/env php $BASEDIR/scripts/whoisonline.php "$@"
