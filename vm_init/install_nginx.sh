#!/bin/sh

# sudo apt update

THIS_DIR=$(pwd)

VERSION=1.18.0
TARBALL_PATH=$HOME/nginx.tar.gz

wget https://nginx.org/download/nginx-$VERSION.tar.gz -O $TARBALL_PATH
tar -C $THIS_DIR -xzf $TARBALL_PATH

rm -rf $TARBALL_PATH

$THIS_DIR/nginx-$VERSION/configure --with-stream
