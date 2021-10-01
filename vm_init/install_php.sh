#!/bin/sh

if [ -z $(which php) ]; then
    # sudo apt install php php-cli php-fpm php-json
    sudo apt install php php-cli php-fpm
fi
