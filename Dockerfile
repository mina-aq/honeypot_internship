FROM sitespeedio/sitespeed.io:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    golang-go \
    git \
    ca-certificates \
    libnss3-tools \
    lynx

WORKDIR /opt

# Install Web Page Replay Go 
RUN git clone https://chromium.googlesource.com/catapult \
    && cd catapult/web_page_replay_go/ \
    && go mod tidy 
    #&& sed -i 's/go 1.23.0/go 1.22/' go.mod 


COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
