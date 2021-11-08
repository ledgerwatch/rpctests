#!/bin/sh -e

# jenkins workspace directory
BASE=$(pwd) # /var/lib/jenkins/workspace/<project_name>

ERIGONREPO="https://github.com/ledgerwatch/erigon.git"
ERIGON_DIR=$BASE/erigon_replay
HASH="HEAD"

for i in "$@"; do
    case $i in
    -b=* | --branch=*)
        BRANCH="${i#*=}"
        shift
        ;;
    -bid=* | --buildid=*) 
        BUILD_ID="${i#*=}"
        shift
        ;;
    -t=* | --timestamp=*) 
        TIMESTAMP="${i#*=}"
        shift
        ;;
    -p=* | --pull=*) 
        PULL="${i#*=}"
        shift
        ;;
    esac
done

if [ -z "$BRANCH" ]; then 
    echo "Branch name is not provided. Expected branch name. Exiting..."
    echo "Usage: ./build.sh -b|--branch=<branch_name>"
    exit 1
fi

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
        git pull # ?
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
        git pull # ?
        git reset --hard "$3"
        cd ..
    fi
}

echo ""
if [ ! "$BRANCH" = "nobranch" ]; then 
    checkout_branch $ERIGONREPO $BRANCH $HASH $ERIGON_DIR
fi

cd $ERIGON_DIR

if [ "$BRANCH" = "nobranch" ]; then 
    if [ "$PULL" = "0" ]; then 
        echo "Not pulling changes from remote repository..."
        echo "Erigon and RPCdaemon will start with existing build..."
        exit 0
    elif [ "$PULL" = "1" ]; then
        git pull
    fi
fi

make erigon
make rpcdaemon
make rpctest

