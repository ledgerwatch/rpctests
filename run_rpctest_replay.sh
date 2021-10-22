#!/bin/sh

# this script allows to run rpc tests in the background process
# the goal:
#       - to keep erigon running after terminal window is closed
#       - testing without running a server

echo "This command will restart Erigon and RPCdaemon. Do you wish to continue? [y/n] (default 'y')"
read ANSWER

if [ -z "$ANSWER" ] || [ "$ANSWER" = "y" ] || [ "$ANSWER" = "yes" ]; then
    echo "Please enter Erigon branch you wish to test (default 'devel'):"
    read ERIGON_BRANCH

    if [ -z "$ERIGON_BRANCH" ]; then
        ERIGON_BRANCH="devel"
    fi
    echo "Erigon branch is set to: $ERIGON_BRANCH"

    echo ""

    echo "Please enter the rcptest branch (default 'main'):"
    read TEST_BRANCH
    if [ -z "$TEST_BRANCH" ]; then
        TEST_BRANCH="main"
    fi
    echo "Rpctest branch is set to: $TEST_BRANCH"

    OUT_FILE=rpctest_replay.out
    echo "Starting rpctest_replay.sh script in background process... see $OUT_FILE for output"
    nohup ./qa_scripts/rpctest_replay.sh $ERIGON_BRANCH $TEST_BRANCH >$OUT_FILE 2>&1 &
elif [ "$ANSWER" = "n" ] || [ "$ANSWER" = "no" ]; then
    exit 0
else
    echo "Unknown input: $ANSWER"
    exit 1
fi
