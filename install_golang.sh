#!/bin/sh

# !!! LINUX AMD64 ONLY

set -e

GOROOT=$HOME/.go
TARBALL_PATH=$HOME/go.tar.gz

remove_go() {
    echo "removing Go..."
    rm -rf $GOROOT
}

download_go() {

    echo "Enter required version: "
    read VERSION
    echo "downloading Go version: $VERSION..."
    sleep 1
    wget "https://golang.org/dl/go$VERSION.linux-amd64.tar.gz" -O $TARBALL_PATH
}

install_go() {
    tar -C $GOROOT -xzf $HOME/go.tar.gz

    printf "\nexport PATH=\$PATH:$GOROOT/go/bin\n" >>~/.profile
    export PATH=$PATH:$GOROOT/go/bin

    go version

    echo "removing tarball..."
    rm -rf $TARBALL_PATH
}

# remove_go
download_go
install_go
