#!/bin/bash -e

# script expects 1 argument: branch name from erigon repo
# kills rpcdaemon process if it is running
# clones erigon repo and checkouts specified branch
# note that erigon repo is cloned into dir "erigon_replay" not to overwrite existing "erigon" dir
# compiles rpctest and rpcdaemon
# runs rpcdaemon
# runs replay for recordFiles from rpctests/geth and rpctests/oe folders agains geth/oe respectively
# results are stored in directory replay<Date_Time> per each file that was run with replay

erigondir="erigon_replay"
rpctestsdir="${PWD##*/}" # name of rpctests dir
resultsdir="replay$(date +%Y%m%d_%H%M%S)"

ERIGONREPO="https://github.com/ledgerwatch/erigon.git"
BRANCH=$1
HASH="HEAD"

RPCTESTREPO="https://github.com/ledgerwatch/rpctests.git"

# DATADIR="/mnt/nvme/data1/"
DATADIR="/home/kairat/diskC/goerli/erigon/"
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

replay_files() {
	# $1 - dir with files
	# $2 - port for geth or oe
	if [ -d "$1" ]; then
		echo "Replaying files from $1"
		cd $1
		for eachfile in *.txt; do
			echo "Replaying file $eachfile"
			nohup $basedir/$erigondir/build/bin/rpctest replay --erigonUrl http://localhost:$2 --recordFile $eachfile 2>&1 >>$basedir/$resultsdir/$eachfile &
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
# ---------- end functions ----------

if [ -z "$BRANCH" ]; then
	echo "Branch to checkout is not provided. Exiting..."
	exit 1
fi

kill_process "rpcdaemon" $RPCDAEMONPORT

basedir=$(cd .. && pwd)
cd $basedir
mkdir $resultsdir

checkout_branch $ERIGONREPO $BRANCH $HASH $basedir/$erigondir
echo $BRANCH >>$basedir/$resultsdir/erigon_branch.txt

cd $basedir/$erigondir
make rpcdaemon
make rpctest

nohup ./build/bin/rpcdaemon --private.api.addr=localhost:9090 --http.port=$RPCDAEMONPORT --http.api=eth,debug,trace --verbosity=4 --datadir "$DATADIR" 2>&1 >>$basedir/$resultsdir/rpcdeamon.log &

newpid=""
until [ ! -z "$newpid" ]; do
	echo "Waiting for rpcdaemon to start on $RPCDAEMONPORT"
	sleep 1
	newpid=$(ps aux | grep rpcdaemon | grep $RPCDAEMONPORT | awk '{print $2}')
done

replay_files $basedir/$rpctestsdir/oe $RPCDAEMONPORT
replay_files $basedir/$rpctestsdir/geth $RPCDAEMONPORT

echo "Check directory $basedir/$resultsdir/ for replay results"
