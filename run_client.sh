#!/bin/sh

BIN_DIR=bin
EXECUTABLE=client
ENTRY_FOLDER=qa_client

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

echo "Enter server IP address:"
read IP
echo "Enter port number:"
read PORT

if [ -z $IP ]; then
    IP=127.0.0.1
fi

if [ -z $PORT ]; then
    PORT=8080
fi

echo IP:$IP PORT:$PORT

./$BIN_DIR/$EXECUTABLE -address=$IP:$PORT
