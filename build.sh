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
checkout_branch $ERIGONREPO $BRANCH $HASH $ERIGON_DIR

cd $ERIGON_DIR

make erigon
make rpcdaemon
make rpctest
