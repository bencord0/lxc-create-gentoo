#!/bin/bash

####################
# Puppet bootstrap #
####################
mkdir -p /etc/portage/package.{use,keywords}

cat << EOF >> /etc/portage/package.use/sys-apps
sys-apps/net-tools old-output
EOF

emerge --usepkg --buildpkg app-admin/puppet

################
# Run services #
################
rc-update add puppet
rc

