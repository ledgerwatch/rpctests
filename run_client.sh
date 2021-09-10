#!/bin/sh

BIN_DIR=bin
EXECUTABLE=client
ENTRY_FOLDER=qa_client

S_PORT=8080 # server port

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...


./$BIN_DIR/$EXECUTABLE -address=127.0.0.1:8080