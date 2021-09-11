#!/bin/sh

### Install all web dependacies ###

set -x

CUR_DIR=$(pwd)

sudo apt-get update

# Nginx installation
if [ -z $(which nginx) ]; then
    sudo apt-get install nginx
fi

if [ "$r" = "Status: inactive" ]; then
    sudo ufw enable
fi

sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'

sudo rm /etc/nginx/sites-ebanbled/default

$CUR_DIR/vm_init/copy_nginx_conf.sh

# PHP and components
$CUR_DIR/vm_init/install_php.sh

echo "

"

echo "Add `stream` block to nginx.conf!"