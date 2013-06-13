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

emerge --usepkg --buildpkg www-servers/nginx

######################
# Configure services #
######################

cat << EOF > /etc/nginx/nginx.conf
user nginx nginx;
worker_processes 1;

error_log /var/log/nginx/error_log info;

events {
        worker_connections 1024;
        use epoll;
}

http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        log_format main
                '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $bytes_sent '
                '"$http_referer" "$http_user_agent" '
                '"$gzip_ratio"';

        client_header_timeout 10m;
        client_body_timeout 10m;
        send_timeout 10m;

        connection_pool_size 256;
        client_header_buffer_size 1k;
        large_client_header_buffers 4 2k;
        request_pool_size 4k;

        gzip on;
        gzip_min_length 1100;
        gzip_buffers 4 8k;
        gzip_types text/plain;

        output_buffers 1 32k;
        postpone_output 1460;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;

        keepalive_timeout 75 20;

        ignore_invalid_headers on;

	index index.html;

	include vhosts/*.vhost;
}
EOF
#------------
# static page
#------------

mkdir -p /etc/nginx/vhosts
cat << EOF > /etc/nginx/vhosts/default.vhost
server {
	listen [::]:80 default_server;
	listen [::]:443 ssl;

	root /var/www/localhost/htdocs;
}
EOF

# Bash variables can be used too!

mkdir -p /var/www/localhost/htdocs
cat << EOF > /var/www/localhost/htdocs/index.html
<h1>Hello World</h1>
<br />
<p>$(hostname -f || hostname)</p>
EOF

################
# Run services #
################

rc-update add nginx
rc
