#!/bin/bash

if [ "$#" -ne 4 ]; then 
    echo "Must have 4 arguments."
    echo "Usage : "
    echo "./record_crawl.sh [path/to/archive] [URL] [certificate] [key]"
    exit 1
fi 


# TODO : check arguments types, if ports already in use, if URL is valid, wait until wpr is ready instead of only sleep 2 etc... 

ARCHIVE="/workdir/$1"
URL=$2
CERT="/workdir/$3"
KEY="/workdir/$4"
#CERT="$3"
#KEY="$4"
current_dir=$(pwd)

export PATH=$PATH:/usr/bin

cd /opt/catapult/web_page_replay_go/
#cd /home/mina/Desktop/stage/catapult/web_page_replay_go

echo "Installing certificat"

mkdir -p /root/.pki/nssdb && certutil -N -d sql:/root/.pki/nssdb --empty-password

go run src/wpr.go installroot --https_cert_file=$CERT --https_key_file=$KEY 

echo "Setting Web Page Replay in replay mode..."
go run src/wpr.go replay --http_port=8080 --https_port=8081 --https_cert_file $CERT --https_key_file $KEY $ARCHIVE > $current_dir/wpr.log 2>&1 &
#--https_key_file="$KEY" --https_cert_file="$CERT"
#go run src/wpr.go replay --http_port=8080 --https_port=8081 --https_cert_file=$CERT --https_key_file=$KEY $current_dir/$ARCHIVE > $current_dir/wpr.log 2>&1 #&
WPR_PID=$!

sleep 2

echo "exec chrome $URL"

#google-chrome --user-data-dir=$bar --headless --no-sandbox --host-resolver-rules="MAP *:80 127.0.0.1:8080,MAP *:443 127.0.0.1:8081,EXCLUDE localhost" --ignore-certificate-errors $URL > $current_dir/chrome.log 2>&1
