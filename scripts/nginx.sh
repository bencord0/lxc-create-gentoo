#!/bin/bash

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
