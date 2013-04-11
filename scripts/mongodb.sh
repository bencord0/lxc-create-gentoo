#!/bin/bash

######################
# Bootstrap packages #
######################

_unkeyword() {
    package="$1"
    category=$(echo "$1"|cut -d/ -f1)
    echo "$package" >> "/etc/portage/package.keywords/$category"
}
_use() {
    package="$1"
    category=$(echo "$1"|cut -d/ -f1)
    shift
    echo "$package $@" >> "/etc/portage/package.use/$category"
}
_mask() {
    package="$1"
    echo "$package" >> "/etc/portage/package.mask"
}
mkdir -p /etc/portage/package.{use,keywords}

_unkeyword app-arch/snappy
_unkeyword dev-db/mongodb
_unkeyword dev-libs/boost
_unkeyword dev-util/boost-build

# Masking due to merge failure
_mask =dev-db/mongodb-2.4.1

emerge --{use,build}pkg mongodb

#####################
# Configure service #
#####################

sed -i 's/MONGODB_IP/#MONGODB_IP/' /etc/conf.d/mongodb

##################
# Start services #
##################

rc-update add mongodb
rc
