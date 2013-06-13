#!/bin/bash
#
# Copyright 2013 Ben Cordero
#
# This file is part of lxc-create-gentoo.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
