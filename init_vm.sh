#!/bin/sh

echo "installing Nginx..."
./vm_init/install_nginx.sh

echo "installing Go..."
./vm_init/install_go.sh
