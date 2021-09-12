#!/bin/sh

PWD=$(pwd)

# ERIGON_BIN=$PWD/erigon/build/bin/erigon
ERIGON_BIN=$PWD/scripting.sh

print_msg() {
    echo "
    $1
    "
}

if [ ! -e $ERIGON_BIN ]; then
    print_msg "Seems like erigon was not built... Can not find binaries... Exiting..."
    exit 1
fi

# TODO check falgs
for i in "$@"; do
    case $i in
    -f1=* | --flag_1=*)
        FLAG_1="${i#*=}"
        shift
        ;;
    -f2=* | --flag_2=*)
        FLAG_2="${i#*=}"
        shift
        ;;
    esac
done

# if some of the required flags are not set
if [ -z $FLAG_1 ]; then
    print_msg "Required flag was not set... Exiting..."
    exit 1
fi

print_msg "Starting erigon process in the background..."
nohup $ERIGON_BIN $FLAG_1 $FLAG_2 &

newpid=""
until [ ! -z "$newpid" ]; do
    echo "Waiting for $ERIGON_BIN to start"
    sleep 1
    echo $(ps aux | grep $ERIGON_BIN)
    newpid=$(ps aux | grep $ERIGON_BIN | awk '{print $2}')
done

echo $newpid
