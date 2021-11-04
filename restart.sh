#!/bin/sh

# jenkins workspace directory
BASE=$(pwd) # /var/lib/jenkins/workspace/<project_name>
ERIGON_DIR=$BASE/erigon_replay

PORT=8548 # reserved rpcdaemon port

# DATADIR="/mnt/nvme/data1" # chaindata dir
DATADIR="/mnt/rd0_0/goerli" # chaindata dir

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


echo "Checking if erigon is running..."
erigon_pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')
# if erigon is running send SIGTERM
if [ -z "$erigon_pid" ]; then
    echo "Erigon process is not running... we good to go."
else
    echo "Found erigon process... PID=$erigon_pid"
    echo "Sending SIGTERM signal to PID=$erigon_pid"
    kill $erigon_pid

    until [ -z "$erigon_pid" ]; do
        echo "Waiting for Erigon to stop..."
        sleep 1
        erigon_pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')
    done

    echo "Erigon has stopped..."
fi

echo "Checking if there is process listening on reserved port: $PORT..."
# rpcdaemon_pid=$(ps aux | grep $1 | grep $2 | awk '{print $2}')
rpcdaemon_pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')
# kill any process running on port reserved for rpcdaemon
if [ ! -z "$rpcdaemon_pid" ]; then
    echo "Found process listening on reserved port $PORT. PID=$rpcdaemon_pid"
    echo "Sending SIGTERM signal to PID=$rpcdaemon_pid"
    kill $rpcdaemon_pid

    pid=$rpcdaemon_pid
    until [ -z "$pid" ]; do
        echo "Waiting for process to stop..."
        sleep 1
        pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')
    done

    echo "Process with PID=$rpcdaemon_pid stopped.."
else
    echo "There is no process listening on reserved port $PORT (rpcdaemon port)..."
fi

limit_lines() {

    # limits redirected output lines to arg $3
    # usage example:
    # command_that_continuously_outputs | limit_lines "file_to_write" "file_helper" "number_of_lines_limit"

    file_name=$1
    file_out=$2
    limit=$3

    touch $file_name
    touch $file_out

    while IFS='' read -r line; do
        line_count=$(wc -l <"$file_name")
        if [ $line_count -gt $limit ]; then
            sed 1d $file_name >$file_out
            {
                cat $file_out
                printf '%s\n' "$line"
            } >$file_name
        else
            echo $line >>$file_name
        fi
    done
}

mkdir -p $RESULTS_DIR

cd $ERIGON_DIR

### start Erigon ###
echo "Starting Erigon..."
nohup ./build/bin/erigon --datadir $DATADIR --chain goerli --private.api.addr=localhost:9090 2>&1 | $(limit_lines "$RESULTS_DIR/erigon.log" "$RESULTS_DIR/_erigon.log" "20") &

erigon_pid=""
count=0
until [ ! -z "$erigon_pid" ]; do
    echo "Waiting for Erigon to start... waited: ${count}s"
    sleep 1
    erigon_pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')

    count=`expr $count + 1`

    if [ $count -gt 30 ]; then 
        echo "Erigon for some reason can't start. Check the logs in $RESULTS_DIR/erigon.log"
        echo "It took too long to start a process... exiting"
        exit 1 # entire build fails
    fi
done
echo ""
echo "----- Erigon successfully started and running in the background. PID=$erigon_pid -----"
echo "----- Erigon logs: $RESULTS_DIR/erigon.log -----"

### start RPCdaemon ###
echo "Starting RPCdaemon..."
nohup ./build/bin/rpcdaemon --private.api.addr=localhost:9090 --http.port=$PORT --http.api=eth,erigon,web3,net,debug,trace,txpool --verbosity=4 --datadir "$DATADIR" 2>&1 | $(limit_lines "$RESULTS_DIR/rpcdaemon.log" "$RESULTS_DIR/_rpcdaemon.log" "20") &

rpcdaemon_pid=""
count=0
until [ ! -z "$rpcdaemon_pid" ]; do
    echo "Waiting for RPCdaemon to start... waited: ${count}s"
    sleep 1
    rpcdaemon_pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')

    count=`expr $count + 1`

    if [ $count -gt 30 ]; then 
        echo "RPCdaemon for some reason can't start. Check the logs in $RESULTS_DIR/rpcdaemon.log"
        echo "It took too long to start a process... exiting"
        exit 1 # entire build fails
    fi
done
echo ""
echo "----- RPCdaemon successfully started and running in the background. PID=$rpcdaemon_pid -----"
echo "----- RPCdaemon logs: $RESULTS_DIR/rpcdaemon.log -----"
echo ""