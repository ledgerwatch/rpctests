#!/bin/sh

### Install all web dependacies ###

set -x

CUR_DIR=$(pwd)

# ---- functions ---- #
# install_go() {}
# install_gcc() {}
# install_nginx() {}
# install_php() {}

sudo apt-get update

# Nginx installation
if [ -z $(which nginx) ]; then
    sudo apt-get install nginx
fi

ufw_status=$(sudo ufw status)
if [ "$ufw_status" = "Status: inactive" ]; then
    sudo ufw enable
fi

sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx Full' # TLS/SSL
sudo ufw allow 12345        # open port for client

sudo $CUR_DIR/vm_init/copy_nginx_conf.sh

# PHP and components
sudo $CUR_DIR/vm_init/install_php.sh

echo ""

echo Add "stream" block to nginx.conf!

echo ""
