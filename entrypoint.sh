#!/bin/bash 

MODE=$1

if [[ "$MODE" == "record" ]]; then
    if [[ "$#" -ne 5 && "$#" -ne 6 ]]; then 
        echo "Must have 5 or arguments."
        echo "Usage : "
        echo "./entrypoint.sh record login [SCRIPT] [CERTIFICATE] [KEY]"
        echo "OR"
        echo "./record_replay.sh record [URL] [depth] [max pages] [certificate] [key]"
        exit 1
    fi 


    # TODO : check arguments types, if ports already in use, if URL is valid, wait until wpr is ready instead of only sleep 2 etc. insert multiple certificates... 

    if [[ "$2" == "login" ]]; then 
        SCRIPT=$3
        CERTS=$4
        KEYS=$5
    else 
        URL=$2
        DEPTH=$3
        MAX_PAGES=$4
        CERTS=$5
        KEYS=$6
    fi

    current_dir=$(pwd)
    OUTPUT_DIR="/workdir/record_logs"

    mkdir -p "$OUTPUT_DIR"

    echo "Setting Web Page Replay in record mode..."
    cd /opt/catapult/web_page_replay_go/
    IFS=',' read -ra cert <<< "$CERTS"
    IFS=',' read -ra key <<< "$KEYS"

    for ((i=0; i<${#cert[@]}; i++)); do
        CERT="/certs/${cert[i]}"
        KEY="/certs/${key[i]}"
    
        go run src/wpr.go installroot --https_cert_file "$CERT" --https_key_file "$KEY" > "$OUTPUT_DIR/wpr.log" 2>&1
    done

    go run src/wpr.go record --http_port=8080 --https_port=8081 --https_cert_file=$CERT --https_key_file=$KEY $current_dir/archive.wprgo > $OUTPUT_DIR/wpr.log 2>&1 &
    WPR_PID=$!
    sleep 2

    if [[ "$2" == "login" ]]; then
        # Uses the script to crawl + visit
        npx sitespeed.io --outputFolder=$OUTPUT_DIR/sitespeed.io_output -n 1 --headless --multi /js_script/$SCRIPT --browsertime.chrome.args="--host-resolver-rules=MAP *:80 127.0.0.1:8080,MAP *:443 127.0.0.1:8081" > $OUTPUT_DIR/sitespeed.log 2>&1
    
    else 
        # Crawls with Lynx then visits with sitespeed.io
        echo "Extracting links to visit..."

        DOMAIN=$(echo $URL | cut -d "/" -f 3)
        echo "$URL" > urls.txt
        
        touch visited.txt

        while read -r url; do
            # Skip if already visited
            grep -qFx "$url" visited.txt && continue

            # Calculate current depth
            current_depth=$(echo "${url%/}" | awk -F/ '{print NF-3}')
            if (( current_depth >= DEPTH )); then
                continue
            fi

            # Mark as visited
            echo "$url" >> visited.txt

            # Extract URLs
            lynx -dump -listonly -nonumbers "$url" | grep "^\(http\|https\)://$DOMAIN" | cut -d '#' -f 1 | sort | uniq >> urls.txt

        done < urls.txt

        # Eliminate doubles 
        awk '!x[$0]++' urls.txt > unique_urls.txt
        
        touch $OUTPUT_DIR/visited_links.txt
        cat unique_urls.txt > $OUTPUT_DIR/visited_links.txt

        echo "Executing sitespeed.io to visit $URL with a depth of $DEPTH..."

        npx sitespeed.io --outputFolder=$OUTPUT_DIR/sitespeed.io_output -n 1 --headless unique_urls.txt --browsertime.chrome.args="--host-resolver-rules=MAP $DOMAIN:80 127.0.0.1:8080,MAP $DOMAIN:443 127.0.0.1:8081" > $OUTPUT_DIR/sitespeed.log 2>&1
        
    fi    

    # Stop Web Page Replay
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

    ARCHIVE="/archive/$2"
    CERT="/certs/$3"
    KEY="/certs/$4"
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