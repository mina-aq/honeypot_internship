FROM python:3.7

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    docker-compose
    #\
    #redis-server

WORKDIR /opt

# Clone SNARE and Tanner 
RUN git clone https://github.com/mushorg/snare.git \
    && git clone https://github.com/mushorg/tanner.git

# Clone PHPOX
#RUN git clone https://github.com/mushorg/phpox.git \
 #   && cd phpox \
  #  && make 


EXPOSE 8080

COPY entrypoint_dockerfile.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint_dockerfile.sh

WORKDIR /workdir

#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/entrypoint_dockerfile.sh"]
