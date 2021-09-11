#!/bin/sh
set -x

if [ -z $(which gcc) ]; then
    sudo apt install build-essential
fi

sudo apt-get install libpcre3 libpcre3-dev # pcre
sudo apt-get install zlib1g-dev            # zlib
