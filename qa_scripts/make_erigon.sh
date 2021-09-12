#!/bin/sh -e

PWD=$(pwd)

ERIGON_REPO="https://github.com/ledgerwatch/erigon.git"

ERIGON_DIR=$PWD/erigon

if [ -d $ERIGON_DIR ]; then
    # repo exist
    echo "Erigon repository exists. Upgrading..."
    cd $ERIGON_DIR && git fetch origin
else
    # repo does not exist
    echo "Erigon repository does not exist. Cloning..."
    git clone --recurse-submodules -j8 $ERIGON_REPO
fi

cd $ERIGON_DIR && make erigon

