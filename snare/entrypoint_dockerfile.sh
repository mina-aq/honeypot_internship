#!/bin/bash

if [ "$#" -ne 2 ]; then 
    echo "Must have 2 arguments."
    echo "Usage : "
    echo "./entrypoint.sh [URL] [max_depth]"
    exit 1
fi 

URL=$1
DEPTH=$2
OUTPUT_DIR="/workdir/output"

mkdir -p $OUTPUT_DIR

echo tannering...
cd /opt/tanner/ 

cd /opt/tanner/docker/
{
    docker-compose build 
    docker-compose up & 
} > $OUTPUT_DIR/tanner.log 2>&1
#TANNER_PID=$!

echo cloning...
cd /opt/snare/
{
    pip3 install -r requirements.txt
    python3 setup.py install
} > $OUTPUT_DIR/snare_install.log 2>&1

clone --target $URL --path /opt/snare --max-depth $DEPTH > $OUTPUT_DIR/clone.log 2>&1

sleep 5 
echo snaring...
snare --page-dir $URL --path /opt/snare --tanner localhost > $OUTPUT_DIR/snare.log 2>&1
