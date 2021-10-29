#!/bin/sh

BASE=$(pwd)
SSL_DIR=$BASE/ssl
CERTS=$SSL_DIR/certs

mkdir -p $CERTS

cd $CERTS

openssl ecparam -name prime256v1 -genkey -noout -out CA-key.pem
openssl req -x509 -new -nodes -key CA-key.pem -sha256 -days 3650 -out CA-cert.pem

openssl ecparam -name prime256v1 -genkey -noout -out server-key.pem # server key
openssl ecparam -name prime256v1 -genkey -noout -out client-key.pem # client key

openssl req -new -key server-key.pem -out server.csr
openssl x509 -req -in server.csr -CA CA-cert.pem -CAkey CA-key.pem -CAcreateserial -out server.crt -days 3650 -sha256 # server crt

openssl req -new -key client-key.pem -out client.csr
openssl x509 -req -in client.csr -CA CA-cert.pem -CAkey CA-key.pem -CAcreateserial -out client.crt -days 3650 -sha256 # client crt
