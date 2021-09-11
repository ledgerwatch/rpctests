#!/bin/sh

### Initalization script. Runs on "fresh" instance. ###

echo "installing Nginx..."
./vm_init/install_web.sh

echo "installing Go..."
./vm_init/install_go.sh
