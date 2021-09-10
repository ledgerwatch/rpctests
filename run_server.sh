#!/bin/sh

BIN_DIR=bin
EXECUTABLE=server
ENTRY_FOLDER=qa_server

S_PORT=8080 # default server port


mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

export SERVER_PORT=$S_PORT

./$BIN_DIR/$EXECUTABLE