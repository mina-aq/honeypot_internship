FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    golang-go \
    git \
    libnss3-tools \
    ca-certificates 

# Install Web Page Replay Go    
WORKDIR /opt
RUN git clone https://chromium.googlesource.com/catapult \
    && cd catapult/web_page_replay_go \
    && sed -i 's/go 1.23.0/go 1.22/' go.mod 

COPY replay.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/replay.sh

WORKDIR /workdir

EXPOSE 8080 8081

ENTRYPOINT ["/usr/local/bin/replay.sh"]