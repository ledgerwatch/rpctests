#!/bin/sh

# !!! LINUX AMD64 ONLY

set -e

TARBALL_PATH=$HOME/go.tar.gz

remove_go() {
    echo "removing Go..."
    rm -rf /usr/local/go
}

download_go() {

    echo "required version: "
    read VERSION
    echo "downloading Go version: $VERSION..."
    wget "https://golang.org/dl/go$VERSION.linux-amd64.tar.gz" -O $TARBALL_PATH

}

install_go() {
    tar -C /usr/local -xzf $HOME/go.tar.gz

    printf "\nexport PATH=$PATH:/usr/local/go/bin\n"
    export PATH=$PATH:/usr/local/go/bin

    go version

    echo "removing tarball..."
    rm -rf $TARBALL_PATH
}

# remove_go()
download_go
install_go

