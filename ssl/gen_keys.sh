#!/bin/sh

BASE=$(pwd)
SSL_DIR=$BASE/ssl
CERTS=$SSL_DIR/certs

mkdir -p $CERTS

cd $CERTS

# touch tls.crt && touch tls.key
if [ ! -e tls.crt ] && [ ! -e tls.key ]; then
    openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out tls.crt -keyout tls.key
fi

openssl x509 -enddate -noout -in tls.crt
