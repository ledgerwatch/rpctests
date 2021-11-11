#!/bin/sh

# jenkins workspace directory
BASE=/var/lib/jenkins/workspace/rpctests # /var/lib/jenkins/workspace/<project_name>
ERIGON_DIR=$BASE/erigon_replay

PORT=8548 # reserved rpcdaemon port

LOGS_DIR="/var/log/erigon"

mkdir -p $LOGS_DIR

for i in "$@"; do
    case $i in
    -bid=* | --buildid=*)
        BUILD_ID="${i#*=}"
        shift
        ;;
    -u=* | --url=*) 
        JENKINS_URL="${i#*=}"
        shift
        ;;
    esac
done

DATADIR_REMOTE="/mnt/nvme/data1" # chaindata dir
DATADIR_LOCAL="/mnt/rd0_0/ropsten" # chaindata dir

if [ ! -z "$JENKINS_URL" ]; then
    if echo "$JENKINS_URL" | grep -q "erigon.dev"; then 
        echo "Determined machine type: Remote VM"
        DATADIR=$DATADIR_REMOTE
        echo "DATADIR is set to $DATADIR_REMOTE"

    elif echo "$JENKINS_URL" | grep -q "localhost" || echo "$JENKINS_URL" | grep -q "127.0.0.1"; then 
        echo "Determined machine type: Local machine"
        DATADIR=$DATADIR_LOCAL
        echo "DATADIR is set to $DATADIR_LOCAL"
    else 
        echo "Can not determine machine. JENKINS_URL=$JENKINS_URL. Exiting..."
        exit 1
    fi
else
    echo "JENKINS_URL argument is empty."
    echo "Can not determine machine. Is it local machine or remote VM?"
    exit 1
fi

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

echo ""
echo "Removing old log files..."
cd $LOGS_DIR
for eachfile in *.log; do
    echo "Removing $eachfile..."
    rm $eachfile
done

echo ""
echo "Removing 'nodes' directory if exists..."
rm -rf $DATADIR/nodes


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

cd $ERIGON_DIR

echo ""

### start Erigon ###
if [ $DATADIR = $DATADIR_REMOTE ]; then  # mainnet
    echo "Starting Erigon..."
    nohup ./build/bin/erigon --datadir $DATADIR --private.api.addr=localhost:9090 2>&1 | $(limit_lines "$LOGS_DIR/erigon.log" "$LOGS_DIR/_erigon.log" "50") &
elif [ $DATADIR = $DATADIR_LOCAL ]; then
    echo "Starting Erigon on ropsten testnet..."
    nohup ./build/bin/erigon --datadir $DATADIR --chain ropsten --private.api.addr=localhost:9090 2>&1 | $(limit_lines "$LOGS_DIR/erigon.log" "$LOGS_DIR/_erigon.log" "50") &
fi


erigon_pid=""
count=0
until [ ! -z "$erigon_pid" ]; do
    echo "Waiting for Erigon to start... waited: ${count}s"
    sleep 1
    erigon_pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')

    count=`expr $count + 1`

    if [ $count -gt 30 ]; then 
        echo "Erigon for some reason can't start. Check the logs in $LOGS_DIR/erigon.log"
        echo "It took too long to start a process... exiting"
        exit 1 # entire build fails
    fi
done
echo "----- Erigon successfully started and running in the background. PID=$erigon_pid -----"
echo "----- Erigon logs: $LOGS_DIR/erigon.log -----"


echo ""
### start RPCdaemon ###
echo "Starting RPCdaemon..."
nohup ./build/bin/rpcdaemon --private.api.addr=localhost:9090 --http.port=$PORT --http.api=eth,erigon,web3,net,debug,trace,txpool --verbosity=4 --datadir "$DATADIR" --ws 2>&1 | $(limit_lines "$LOGS_DIR/rpcdaemon.log" "$LOGS_DIR/_rpcdaemon.log" "20") &

rpcdaemon_pid=""
count=0
until [ ! -z "$rpcdaemon_pid" ]; do
    echo "Waiting for RPCdaemon to start... waited: ${count}s"
    sleep 1
    rpcdaemon_pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')

    count=`expr $count + 1`

    if [ $count -gt 30 ]; then 
        echo "RPCdaemon for some reason can't start. Check the logs in $LOGS_DIR/rpcdaemon.log"
        echo "It took too long to start a process... exiting"
        exit 1 # entire build fails
    fi
done
echo "----- RPCdaemon successfully started and running in the background. PID=$rpcdaemon_pid -----"
echo "----- RPCdaemon logs: $LOGS_DIR/rpcdaemon.log -----"