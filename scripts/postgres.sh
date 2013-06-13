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
####################
# Install packages #
####################

emerge --{use,build}pkg dev-db/postgresql-server

#######################
# Configuring service #
#######################
PV=$(basename /etc/init.d/postgresql*|cut -d- -f2-)

rc-update add postgresql-$PV
echo -e 'y\n' | emerge --config dev-db/postgresql-server:$PV
echo "listen_addresses = '*'"      >> /etc/postgresql-$PV/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql-$PV/pg_hba.conf
echo "host all all ::/0 md5"      >> /etc/postgresql-$PV/pg_hba.conf

################
# Run services #
################
rc

# Scramble the password
PASSKEY=$(uuidgen|sed 's/-//g')
psql -U postgres -c "ALTER USER postgres with password '$PASSKEY';" 2>&1 >/dev/null

echo "Postgres connection on: psql -U postgres -h $(hostname -f||hostname)"
echo "Postgres password is: $PASSKEY"
