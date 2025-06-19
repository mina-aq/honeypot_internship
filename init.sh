#!/bin/bash 

dir=$(pwd)
if [ "$#" -eq 2 ]; then 
    # Load the provided certificate + key
    CERT=$dir/$1
    KEY=$dir/$2
elif [ "$#" -eq 0 ]; then 
    # Generate a new certificate + key 
    openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
    CERT=$dir/"cert.pem"
    KEY=$dir/"key.pem"
fi

# Install google-chrome ? nss database 


# Install certificate 
git clone https://chromium.googlesource.com/catapult 
cd catapult/web_page_replay_go/ 
sed -i 's/go 1.23.0/go 1.22/' go.mod 
go run src/wpr.go installroot --https_cert_file $CERT --https_key_file $KEY
