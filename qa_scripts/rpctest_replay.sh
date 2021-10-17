#!/bin/sh -e

# script expects 1 argument: branch name from erigon repo
# kills rpcdaemon process if it is running
# clones erigon repo and checkouts specified branch
# note that erigon repo is cloned into dir "erigon_replay" not to overwrite existing "erigon" dir
# compiles rpctest and rpcdaemon
# runs rpcdaemon
# runs replay for recordFiles from rpctests/geth and rpctests/oe folders agains geth/oe respectively
# results are stored in directory replay<Date_Time> per each file that was run with replay

BASE=$(pwd)
ERIGON_DIR=$BASE/erigon_replay
WEB_DIR=$BASE/web
RPCTEST_RESULTS_DIR=$WEB_DIR/rpctest_results
RESULTS_DIR_NAME="replay$(date +%Y%m%d_%H%M%S)"
RESULTS_DIR=$RPCTEST_RESULTS_DIR/$RESULTS_DIR_NAME

ERIGONREPO="https://github.com/ledgerwatch/erigon.git"
BRANCH=$1
HASH="HEAD"

DATADIR="/home/kairat/diskC/goerli" # change this
CHAIN="goerli"                      # change this

RPCDAEMONPORT=8548
GETHPORT=9545
OEPORT=9546

# ---------- functions ----------
checkout_branch() {
    # $1 - repo
    # $2 - branch
    # $3 - tag
    # $4 - dir
    if [ -d "$4" ]; then
        echo "Directory $4 exists."
        cd $4
        echo "Upgrading repository ..."
        git fetch origin
        git checkout --force "$2"
        git reset --hard "$3"
        cd ..
    else
        echo "Creating new repository in $4..."
        mkdir $4
        cd $4
        git init .
        git remote add origin "$1"
        git fetch origin
        git checkout --force "$2"
        git reset --hard "$3"
        cd ..
    fi
}

limit_lines() {

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

replay_files() {
    # $1 - dir with files
    # $2 - port for geth or oe
    if [ -d "$1" ]; then
        echo "Replaying files from $1"
        cd $1
        for eachfile in *.txt; do
            echo "Replaying file $eachfile"
            # nohup $ERIGON_DIR/build/bin/rpctest replay --erigonUrl http://localhost:$2 --recordFile $eachfile 2>&1 >>$RESULTS_DIR/$eachfile &

            nohup $ERIGON_DIR/build/bin/rpctest replay --erigonUrl http://localhost:$2 --recordFile $eachfile 2>&1 | $(limit_lines "$RESULTS_DIR/$eachfile" "$RESULTS_DIR/_$eachfile" 20) &
        done
    fi
}

kill_process() {
    # $1 - process name
    # $2 - port
    if [ ! -z "$1" ]; then
        RPCDAEMONPID=$(ps aux | grep $1 | grep $2 | awk '{print $2}')
        if [ -z "$RPCDAEMONPID" ]; then
            echo "no process $1 running on port $2"
        else
            echo "killing $1 on port $2 with pid $RPCDAEMONPID"
            kill $RPCDAEMONPID
        fi
    fi
}

kill_erigon() {
    pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')
    if [ -z "$pid" ]; then
        echo "Erigon process is not running, so not killing..."
    else
        echo "Killing Erigon... PID=$pid"
        kill $pid

        until [ -z "$pid" ]; do
            echo "Waiting for erigon to shut down..."
            sleep 1
            pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')
        done
    fi
}

start_erigon() {
    # nohup ./build/bin/erigon --datadir $DATADIR --chain $CHAIN --private.api.addr=localhost:9090 2>&1 >>$RESULTS_DIR/erigon.log &

    nohup ./build/bin/erigon --datadir $DATADIR --chain $CHAIN --private.api.addr=localhost:9090 2>&1 | $(limit_lines "$RESULTS_DIR/erigon.log" "$RESULTS_DIR/_erigon.log" "20") &
}

start_rpcdaemon() {
    # nohup ./build/bin/rpcdaemon --private.api.addr=localhost:9090 --http.port=$RPCDAEMONPORT --http.api=eth,erigon,web3,net,debug,trace,txpool --verbosity=4 --datadir "$DATADIR" 2>&1 >>$RESULTS_DIR/rpcdeamon.log &

    nohup ./build/bin/rpcdaemon --private.api.addr=localhost:9090 --http.port=$RPCDAEMONPORT --http.api=eth,erigon,web3,net,debug,trace,txpool --verbosity=4 --datadir "$DATADIR" 2>&1 | $(limit_lines "$RESULTS_DIR/rpcdaemon.log" "$RESULTS_DIR/_rpcdaemon.log" "20") &
}

# ---------- end functions ----------

if [ -z "$BRANCH" ]; then
    echo "Branch to checkout is not provided. Exiting..."
    exit 1
fi

kill_erigon

kill_process "rpcdaemon" $RPCDAEMONPORT

mkdir -p $RESULTS_DIR

# checkout_branch $ERIGONREPO $BRANCH $HASH $basedir/$erigondir
checkout_branch $ERIGONREPO $BRANCH $HASH $ERIGON_DIR
echo $BRANCH >>$RESULTS_DIR/erigon_branch.txt

cd $ERIGON_DIR
make erigon
make rpcdaemon
make rpctest

echo $RESULTS_DIR

# START ERIGON
start_erigon

erigon_pid=""
until [ ! -z "$erigon_pid" ]; do
    echo "Waiting for erigon to start..."
    sleep 1
    erigon_pid=$(ps aux | grep ./build/bin/erigon | grep datadir | awk '{print $2}')
done

# START RPCDAEMON
start_rpcdaemon

rpcdaemon_pid=""
until [ ! -z "$rpcdaemon_pid" ]; do
    echo "Waiting for rpcdaemon to start on $RPCDAEMONPORT"
    sleep 1
    rpcdaemon_pid=$(ps aux | grep rpcdaemon | grep $RPCDAEMONPORT | awk '{print $2}')
done

replay_files $BASE/oe $RPCDAEMONPORT
replay_files $BASE/geth $RPCDAEMONPORT
