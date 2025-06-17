FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    git \
    libnss3-tools \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable

RUN wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz \
    && rm go1.23.0.linux-amd64.tar.gz \
    && ln -s /usr/local/go/bin/go /usr/bin/go

WORKDIR /opt
RUN git clone https://chromium.googlesource.com/catapult \
    && cd catapult/web_page_replay_go \
    && go mod tidy

COPY replay.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/replay.sh

WORKDIR /workdir

EXPOSE 8080 8081

ENTRYPOINT ["/usr/local/bin/replay.sh"]