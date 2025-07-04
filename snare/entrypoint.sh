#!/bin/bash

if [ "$#" -ne 2 ]; then 
    echo "Must have 2 arguments."
    echo "Usage : "
    echo "./entrypoint.sh [URL] [max_depth]"
    exit 1
fi 

URL=$1
DEPTH=$2


cd /opt/snare/
{
    pip3 install -r requirements.txt 
    pip install setuptools 
    python3 setup.py install
} > "/workdir/snare_install.log" 2>&1

echo "Clone starting..."
clone --target $URL --path "/workdir/" --max-depth $DEPTH > "/workdir/clone.log" 2>&1 

#apt-get install -y redis-server
echo phpox
cd /opt/phpox/
python3 sandbox.py > "/workdir/phpox.log" > "/workdir/phpox.logs" 2>&1 &
PHPOX_PID=$!

cd /opt/
git clone https://github.com/mushorg/tanner.git
cd tanner 
echo ici
pip3 install -r requirements.txt
echo cb
python3 setup.py install
echo ok
tanner &
TANNER_PID=$!


echo "Clone finished. Starting replay..."
snare --port 8080 --page-dir $URL --path "/workdir/" --tanner 127.0.0.1

