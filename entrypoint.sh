#!/bin/bash 

MODE=$1

if [[ "$MODE" == "record" ]]; then
    if [ "$#" -ne 6 ]; then 
        echo "Must have 6 arguments."
        echo "Usage : "
        echo "./record_replay.sh record [URL] [depth] [max pages] [certificate] [key]"
        exit 1
    fi 


    # TODO : check arguments types, if ports already in use, if URL is valid, wait until wpr is ready instead of only sleep 2 etc... 

    URL=$2
    DEPTH=$3
    MAX_PAGES=$4
    CERT="/workdir/$5"
    KEY="/workdir/$6"
    current_dir=$(pwd)
    OUTPUT_DIR="/workdir/record_logs"

    mkdir -p "$OUTPUT_DIR"

    echo "Setting Web Page Replay in record mode..."
    cd /opt/catapult/web_page_replay_go/
    go run src/wpr.go installroot --https_cert_file $CERT --https_key_file $KEY 
    go run src/wpr.go record --http_port=8080 --https_port=8081 --https_cert_file=$CERT --https_key_file=$KEY $current_dir/archive.wprgo > $OUTPUT_DIR/wpr.log 2>&1 &
    WPR_PID=$!
    sleep 2

    echo "Executing browsertime to visit $URL with a depth of $DEPTH..."
    echo "This operation might take some time..."           

    npx sitespeed.io -d $DEPTH -n 1 -m $MAX_PAGES --outputFolder=$OUTPUT_DIR/sitespeed.io_output --headless $URL --browsertime.chrome.args="--host-resolver-rules='MAP *:80 127.0.0.1:8080,MAP *:443 127.0.0.1:8081,EXCLUDE localhost' --ignore-certificate-errors" > $OUTPUT_DIR/sitespeed.log 2>&1


    child_pids=$(pgrep -P $WPR_PID)
    if [ -n "$child_pids" ]; then
        kill -INT $child_pids
    fi
    kill -INT $WPR_PID
    wait $WPR_PID

    echo "Web Page Replay logs are saved in $OUTPUT_DIR/wpr.log"
    echo "sitespeed.io logs are saved in $OUTPUT_DIR/sitespeed.log"

    echo "Execution done"

elif [[ "$MODE" == "replay" ]]; then
    if [ "$#" -ne 4 ]; then 
        echo "Must have 4 arguments."
        echo "Usage : "
        echo "./record_crawl.sh replay [archive] [certificate] [key]"
        exit 1
    fi 


    # TODO : check arguments types, wait until wpr is ready instead of only sleep 2 etc... 

    ARCHIVE="/workdir/$2"
    CERT="/workdir/$3"
    KEY="/workdir/$4"
    current_dir=$(pwd)
    OUTPUT_DIR="/workdir/replay_logs"

    mkdir -p "$OUTPUT_DIR"

    export PATH=$PATH:/usr/bin

    cd /opt/catapult/web_page_replay_go/

    echo "Setting Web Page Replay in replay mode..."
    go run src/wpr.go replay --host=0.0.0.0 --http_port=8080 --https_port=8081 --https_cert_file $CERT --https_key_file $KEY $ARCHIVE > $OUTPUT_DIR/wpr.log 2>&1 &
    WPR_PID=$!

    sleep 2

    wait $WPR_PID

else
    echo "Unknown mode: $MODE"
    echo "Usage: record ... | replay ..."
    exit 1
fi