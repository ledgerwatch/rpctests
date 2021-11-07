#!/bin/sh


LOGS_DIR="/var/log/rpctests"

for i in "$@"; do
    case $i in
    -bid=* | --buildid=*) 
        BUILD_ID="${i#*=}"
        shift
        ;;
    esac
done

LAST_BUILD_DIR="$LOGS_DIR/$BUILD_ID"

echo "Removing all directories in $LOGS_DIR except the last build=$BUILD_ID"
for dir in $LOGS_DIR/*; do 

    if [ ! $dir = $LAST_BUILD_DIR ]; then 
        echo "Removing directory $dir..."
        rm -rf $dir
    fi

done

