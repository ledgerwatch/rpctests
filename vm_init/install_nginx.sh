#!/bin/sh

sudo apt update && sudo upt install nginx --with-stream
sudo ufw allow 'Nginx HTTP'

sudo cp ./vm_init/tcp_host.conf /etc/nginx/sites-enabled/

sudo nginx -t
# TODO error check

sudo systemctl reload nginx
