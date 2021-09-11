#!/bin/sh

if [ -z $(which php) ]; then
    sudo apt install php php-cli php-fpm php-json
fi