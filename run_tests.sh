#!/bin/sh

# jenkins workspace directory
BASE=$(pwd) # /var/lib/jenkins/workspace/<project_name>
ERIGON_DIR=$BASE/erigon_replay

PORT=8548 # reserved rpcdaemon port

LOGS_DIR="/home/kairat/erigon_logs"

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

RESULTS_DIR=$LOGS_DIR/$BUILD_ID 

date_time="$(date +%Y%m%d_%H%M%S)"

replay_files() {
    # $1 - dir with files
    # $2 - port for geth or oe
    if [ -d "$1" ]; then
        echo "Replaying files from $1"
        cd $1

        for eachfile in *.txt; do
            echo "Replaying file $eachfile"


            tail -n 20 $eachfile
            # temp_file=$RESULTS_DIR/_temp.txt

            # # redirect output to temp file
            # nohup $ERIGON_DIR/build/bin/rpctest replay --erigonUrl http://localhost:$2 --recordFile $eachfile >$temp_file 2>$temp_file &

            # wait $!      # wait untill last executed process finishes
            # exit_code=$? # grab the code

            # tail -n 20 $temp_file >>$RESULTS_DIR/$eachfile

            # rm $temp_file

            # if [ ! "$exit_code" = 0 ]; then 
            #     echo "Unsuccessfull test result: for $eachfile."
            #     echo "Check $RESULTS_DIR/$eachfile."
            #     exit 1
            # fi

        done

    fi
}

replay_files $BASE/queries $PORT

