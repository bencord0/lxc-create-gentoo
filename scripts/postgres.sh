#!/bin/bash

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
