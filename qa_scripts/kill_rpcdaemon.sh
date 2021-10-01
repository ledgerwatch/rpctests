#!/bin/sh -e

RPCDAEMONPORT=8548

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

kill_process "rpcdaemon" $RPCDAEMONPORT
