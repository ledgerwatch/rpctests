#!/bin/sh

kill_process() {
    # $1 - process name
    # $2 - port

    if [ ! -z "$1" ]; then
        RPCDAEMONPID=$(ps aux | grep $1 | grep $2 | awk '{print $2}')
        if [ -z "$RPCDAEMONPID" ]; then
            print_msg "no process $1 running on port $2"
        else
            print_msg "killing $1 on port $2 with pid $RPCDAEMONPID"
            kill $RPCDAEMONPID
        fi
    fi
}

print_msg() {
    echo "
    "$1"
    "
}

print_help() {
    echo "
    Program:
        Finds the process by its name and port number it is using and kills it.
        Both process name and port number have to provided

    Usage: kill_process.sh [Options]

    Options:
        --process_name|-n  name of the process to kill
        --port|-p          port number process is running on
    "
}

if [ -z "$1" ]; then
    print_help
    exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_help
    exit 0
fi

for i in "$@"; do
    case $i in
    -n=* | --process_name=*)
        PROCESS_NAME="${i#*=}"
        shift
        ;;
    -p=* | --port=*)
        PORT="${i#*=}"
        shift
        ;;
    esac
done

if [ -z "$PROCESS_NAME" ] || [ -z "$PORT" ]; then
    echo "
    Process name and/or port argument is empty
        Process name: $PROCESS_NAME
        Port: $PORT
    "
    exit 1
fi

kill_process $PROCESS_NAME $PORT
