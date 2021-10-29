#!/bin/sh

BIN_DIR=bin
EXECUTABLE=client
ENTRY_FOLDER=qa_client

GCP_ADDRESS="34.105.200.219:12345"
LOCAL_ADDRESS="127.0.0.1:8080"

DEFAULT_MODE=gcp # default mode
for i in "$@"; do
    case $i in
    -m=* | --mode=*)
        MODE="${i#*=}"
        shift
        ;;
    esac
done

print_usage() {
    echo "Usage: ./run_client.sh -m|--mode=<mode>
        <mode>: gcp | local
            gcp   - client mode for connecting to the server running on GCP VM instance
            local - client mode for connecting to the local server
    "
}

if [ -z "$MODE" ]; then
    print_usage
    echo "Falling back to default client mode: $DEFAULT_MODE"
    MODE=$DEFAULT_MODE
elif [ ! -z "$MODE" ]; then
    if [ "$MODE" != "gcp" ] && [ "$MODE" != "local" ]; then
        echo "Unknown client mode: $MODE"
        echo "Falling back to default client mode: $DEFAULT_MODE"
        MODE=$DEFAULT_MODE
    else
        echo "Client mode set to: $MODE"
    fi
fi

if [ "$MODE" = "gcp" ]; then
    HOST=$GCP_ADDRESS
elif [ "$MODE" = "local" ]; then
    HOST=$LOCAL_ADDRESS
else
    echo "Unknown mode: $MODE"
    exit 1
fi

mkdir -p $BIN_DIR

go build -o $BIN_DIR/$EXECUTABLE ./$ENTRY_FOLDER/...

./$BIN_DIR/$EXECUTABLE -address="$HOST"
