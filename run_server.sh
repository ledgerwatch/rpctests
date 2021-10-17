#!/bin/sh

BIN_DIR=bin
EXECUTABLE=server
ENTRY_FOLDER=qa_server

for i in "$@"; do
    case $i in
    -m=* | --mode=*)
        MODE="${i#*=}"
        shift
        ;;
    esac
done

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

./$BIN_DIR/$EXECUTABLE -mode $MODE
