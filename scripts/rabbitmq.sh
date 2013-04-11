#!/bin/bash

######################
# Bootstrap packages #
######################

_unkeyword() {
    package="$1"
    category=$(echo "$1"|cut -d/ -f1)
    echo "$package" >> "/etc/portage/package.keywords/$category"
}
mkdir -p /etc/portage/package.keywords

_unkeyword net-misc/rabbitmq-server

emerge -f --{use,build}pkg net-misc/rabbitmq-server

##################
# Start services #
##################

rc-update add rabbitmq
rc
