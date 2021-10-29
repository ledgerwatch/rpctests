#!/bin/sh

BIN_DIR=bin
EXECUTABLE=server

PORT=8080

server_pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')

if [ ! -z "$server_pid" ]; then
    echo "Found process listening on port $PORT. PID=$server_pid"
    echo "Do you want me to kill this process? [y/n] (default 'y'):"
    read ANSWER

    if [ -z "$ANSWER" ] || [ $ANSWER = "y" ]; then
        echo "Killing process with PID: $server_pid"
        kill $server_pid
    else
        if [ ! "$ANSWER" = "n" ]; then
            echo "Unknown input: $ANSWER, guessing this means 'n'"
        fi
        echo "Not killing process with PID: $server_pid"
        exit 1
    fi

else

    echo "There is no process listening on port $PORT... we good to go"
fi
