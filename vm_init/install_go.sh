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

    if [ -d $GOROOT ]; then
        remove_go
    fi

    echo "Enter required version: "
    read VERSION
    echo "downloading Go version: $VERSION..."
    echo ""
    sleep 1
    wget "https://golang.org/dl/go$VERSION.linux-amd64.tar.gz" -O $TARBALL_PATH
}

install_go() {
    mkdir -p $GOROOT

    tar -C $GOROOT -xzf $HOME/go.tar.gz

    printf "\nexport PATH=\$PATH:$GOROOT/go/bin\n" >>~/.profile
    export PATH=$PATH:$GOROOT/go/bin

    go version

    rm -rf $TARBALL_PATH

    echo "
    
        Go-lang installed. Re-login or reopen terminal to apply changes...
    "
}

download_go
install_go
