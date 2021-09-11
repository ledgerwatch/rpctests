#!/bin/sh

### Install all web dependacies ###

set -x

sudo apt-get update

# Nginx installation
if [ -z $(which nginx) ]; then
    sudo apt-get install nginx
fi

sudo ufw enable

sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'

sudo rm /etc/nginx/sites-ebanbled/default

CUR_DIR=$(pwd)
sudo cp $CUR_DIR/web/web.conf /etc/nginx/sites-enabled/

sudo nginx -t
sudo systemctl reload nginx

# PHP and components
if [ -z $(which php) ]; then
    sudo apt install php php-cli php-fpm php-json
fi
