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

    #curl -LO https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
#tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
#export PATH="/usr/local/go/bin:$PATH"


COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
