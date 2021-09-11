#!/bin/sh

CUR_DIR=$(pwd)
sudo cp $CUR_DIR/web/web.conf /etc/nginx/sites-enabled/

sudo mkdir -p /etc/nginx/stream-enabled/
sudo cp $CUR_DIR/web/tcp.conf

sudo nginx -t
sudo systemctl reload nginx
