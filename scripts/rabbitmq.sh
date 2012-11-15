#!/bin/bash

if [ "a$1" == "a" ];
then
	VHOST="test"
else
	VHOST=$1
fi

function run_host {
	echo -e "Running rabbitmqctl $1 -p $VHOST:"
	/usr/sbin/rabbitmqctl $1 -p $VHOST | grep -v '...done.' | grep -v "Listing"
	echo -e ""
}

function run {
	echo -e "Running rabbitmqctl $1:"
	/usr/sbin/rabbitmqctl $1 | grep -v '...done.' | grep -v "Listing"
	echo -e ""
}

echo -e "Running for host: $VHOST\n"

run_host list_permissions
#run_host list_user_permissions
run_host list_queues
run_host list_exchanges
run_host list_bindings
run_host list_consumers

run list_connections
run list_channels
