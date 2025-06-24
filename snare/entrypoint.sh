
if [ "$#" -ne 2 ]; then 
    echo "Must have 2 arguments."
    echo "Usage : "
    echo "./entrypoint.sh [URL] [max_depth]"
    exit 1
fi 

URL=$1
DEPTH=$2


sudo pip3 install -r requirements.txt
sudo python3 setup.py install
sudo clone --target $URL --path <path to base dir> --max_depth $DEPTH