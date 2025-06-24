FROM sitespeedio/sitespeed.io:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    git 


# Clone SNARE 
RUN git clone https://github.com/mushorg/snare.git \
    cd snare


COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
