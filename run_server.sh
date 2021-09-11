#!/bin/sh

BIN_DIR=bin
EXECUTABLE=server
ENTRY_FOLDER=qa_server

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

./$BIN_DIR/$EXECUTABLE
