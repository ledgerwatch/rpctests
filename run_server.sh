#!/bin/sh

BIN_DIR=bin
EXECUTABLE=server
ENTRY_FOLDER=qa_server

DEFAULT_MODE=gcp # default mode, setup to run on GCP VM
for i in "$@"; do
    case $i in
    -m=* | --mode=*)
        MODE="${i#*=}"
        shift
        ;;
    esac
done

print_usage() {
    echo "Usage: ./run_server.sh -m|--mode=<mode>
        <mode>: gcp | local
            gcp   - server mode for GCP VM instance
            local - server mode for local development
    "
}

if [ -z "$MODE" ]; then
    print_usage
    echo "Falling back to default server mode: $DEFAULT_MODE"
    MODE=$DEFAULT_MODE
elif [ ! -z "$MODE" ]; then
    if [ ! "$MODE" = "gcp" ] && [ ! "$MODE" = "local" ]; then
        echo "Unknown server mode: $MODE"
        echo "Falling back to default server mode: $DEFAULT_MODE"
        MODE=$DEFAULT_MODE
    else
        echo "Server mode set to: $MODE"
    fi
fi

PORT=8080
server_pid=$(lsof -n -i :$PORT | grep LISTEN | awk '{print $2}')

if [ ! -z "$server_pid" ]; then
    echo "There is a process that is already listening on port: $PORT. Process PID=$server_pid, Process name: $(ps -q $server_pid -o comm=)"

    echo ""
    echo "Do you want me to kill this process? [y/n] (default 'y'):"
    read ANSWER

    if [ -z "$ANSWER" ] || [ $ANSWER = "y" ]; then
        echo "Killing process with PID: $server_pid"
        kill $server_pid
    else
        if [ ! "$ANSWER" = "n" ]; then
            echo "Unknown input: $ANSWER, guessing this means 'n'"
            exit 1
        fi
        echo "Not killing process with PID: $server_pid"
        exit 0
    fi

else

    echo "There is no process that is using port: $PORT... we good to go"
fi

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

SERVER_LOG=server_out.log
echo "Starting server in background process... see $SERVER_LOG for logs"
nohup ./$BIN_DIR/$EXECUTABLE -mode $MODE >$SERVER_LOG 2>&1 &
