#!/bin/sh
set -x

# make, gcc 
if [ -z $(which gcc) ]; then
    sudo apt install build-essential
fi
