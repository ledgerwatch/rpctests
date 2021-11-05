#!/bin/sh

# jenkins workspace directory
BASE=$(pwd) # /var/lib/jenkins/workspace/<project_name>
ERIGON_DIR=$BASE/erigon_replay

LOGS_DIR="/home/kairat/erigon_logs"

for i in "$@"; do
    case $i in
    -bid=* | --buildid=*) 
        BUILD_ID="${i#*=}"
        shift
        ;;
    esac
done

LAST_BUILD_DIR="$LOGS_DIR/$BUILD_ID"

echo "Removing all directories in $LOGS_DIR except last build=$BUILD_ID"
for dir in $LOGS_DIR/*; do 

    if [ ! $dir = $LAST_BUILD_DIR ]; then 
        echo "Removing directory $dir..."
        # rm -rf $dir
    else 
        echo "Diectory $LAST_BUILD_DIR is not touched..."
    fi

done

