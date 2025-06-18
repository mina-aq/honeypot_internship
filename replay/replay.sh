#!/bin/bash

if [ "$#" -ne 3 ]; then 
    echo "Must have 3 arguments."
    echo "Usage : "
    echo "./record_crawl.sh [path/to/archive] [certificate] [key]"
    exit 1
fi 


# TODO : check arguments types, wait until wpr is ready instead of only sleep 2 etc... 

ARCHIVE="/workdir/$1"
CERT="/workdir/$2"
KEY="/workdir/$3"
current_dir=$(pwd)

export PATH=$PATH:/usr/bin

cd /opt/catapult/web_page_replay_go/

echo "Setting Web Page Replay in replay mode..."
go run src/wpr.go replay --host=0.0.0.0 --http_port=8080 --https_port=8081 --https_cert_file $CERT --https_key_file $KEY $ARCHIVE > $current_dir/wpr.log 2>&1 &
WPR_PID=$!

sleep 2

wait $WPR_PID