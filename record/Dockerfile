FROM sitespeedio/sitespeed.io:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    golang-go \
    git \
    ca-certificates \
    libnss3-tools

WORKDIR /opt

# Install Web Page Replay Go 
RUN git clone https://chromium.googlesource.com/catapult \
    && cd catapult/web_page_replay_go/ \
    && sed -i 's/go 1.23.0/go 1.22/' go.mod 
    #\
#    && go run src/wpr.go installroot --https_cert_file ecdsa_cert.pem --https_key_file ecdsa_key.pem \
#    && go run src/wpr.go installroot --https_cert_file wpr_cert.pem --https_key_file wpr_key.pem 

COPY record_crawl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/record_crawl.sh

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/record_crawl.sh"]
