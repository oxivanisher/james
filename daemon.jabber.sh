#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

cd $BOTDIR
echo -e "XMPP Daemon starting. Hit ctrl+c for clean shutdown"
/usr/bin/env python ./james.py
