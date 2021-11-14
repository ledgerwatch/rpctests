#!/bin/sh

PORT=8548 # reserved rpcdaemon port

echo "Stop erigon and rpcdaemon"

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

echo "Done..."