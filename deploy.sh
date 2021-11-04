#!/bin/sh

BASE=$(pwd)

for i in "$@"; do
    case $i in
    -bid=* | --buildid=*)
        BUILD_ID="${i#*=}"
        shift
        ;;
    -t=* | --timestamp=*) 
        TIMESTAMP="${i#*=}"
        shift
        ;;
    esac
done


echo "it is a deploy/release script"
echo "build_id: $BUILD_ID"
