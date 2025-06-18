#!/bin/bash

if [ "$#" -ne 5 ]; then 
    echo "Must have 5 arguments."
    echo "Usage : "
    echo "./record_crawl.sh [URL] [depth] [max pages] [certificate] [key]"
    exit 1
fi 


# TODO : check arguments types, if ports already in use, if URL is valid, wait until wpr is ready instead of only sleep 2 etc... 

URL=$1
DEPTH=$2
MAX_PAGES=$3
CERT="/workdir/$4"
KEY="/workdir/$5"
current_dir=$(pwd)

echo "Setting Web Page Replay in record mode..."
cd /opt/catapult/web_page_replay_go/
go run src/wpr.go installroot --https_cert_file $CERT --https_key_file $KEY 
go run src/wpr.go record --http_port=8080 --https_port=8081 --https_cert_file=$CERT --https_key_file=$KEY $current_dir/archive.wprgo > $current_dir/wpr.log 2>&1 &
WPR_PID=$!
sleep 2

echo "Executing browsertime to visit $URL with a depth of $DEPTH..."
echo "This operation might take some time..."           

npx sitespeed.io -d $DEPTH -n 1 -m $MAX_PAGES --outputFolder=$current_dir/sitespeed.io_output --headless $URL --browsertime.chrome.args="--host-resolver-rules='MAP *:80 127.0.0.1:8080,MAP *:443 127.0.0.1:8081,EXCLUDE localhost' --ignore-certificate-errors" > $current_dir/sitespeed.log 2>&1


child_pids=$(pgrep -P $WPR_PID)
if [ -n "$child_pids" ]; then
    kill -INT $child_pids
fi
kill -INT $WPR_PID
wait $WPR_PID

echo "Web Page Replay logs are saved in $current_dir/wpr.log"
echo "sitespeed.io logs are saved in $current_dir/sitespeed.log"

echo "Execution done"
