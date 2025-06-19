### RECORD AND REPLAY A PAGE

This repository has a Dockerfile to build an image that can be used in two modes : to record a website and to replay what was recorded.
Tested only on Ubuntu. 

## Used tools

In record mode, this docker uses Web Page Replay to record the visited sites and saves them in an archive.
The tool sitespeed.io is also used as a crawler to orchestrate Web Page Replay to visit the site and its subpages. 

In replay mode, this docker uses Web Page Replay to replay the previously visited pages. 


## Prerequisites : 

* You need to install Docker with the right configuration : 
    - https://docs.docker.com/engine/install/ubuntu/
    - https://docs.docker.com/engine/install/linux-postinstall/

* Go with version >= 1.23.0 : 
    - https://go.dev/doc/install

* google-chrome


## Initialize 

Before beginning, run : 
```
chmod +x init.sh 
./init.sh 
```

This script will generate a PEM certificate and key. To use your own certificate, run :
```
./init.sh <your certificate> <your key>
```


## Build the docker image

``` 
 docker build -t <image_name> .
```


## Record 

To run the created image : 
```
docker run --rm -v "$(pwd):/workdir" <image_name> record <URL> <DEPTH> <MAX_PAGES> <CERTIFICATE> <KEY>
```
Where <URL> is the page you want to record by specifying the crawl depth with <DEPTH> and the maximum number of visited pages with <MAX_PAGES>.

In the output, you will have : 
- archive.wprgo : archive file of the recorded site. Used for the replay [insert link to replay page]
- record_logs/wpr.log : logs of the tool Web Page Replay which is used in recording mode.
- record_logs/sitespeed.log : logs of the tool sitespeed.io which is used to vite the URL you want to record.
- record_logs/sitespeed.io_output : output folder of sitespeed.io containing metrics, HAR files, etc... 


## Replay 

To run the created image : 
```
docker run --rm -d -v "$(pwd):/workdir" -p <port1>:8080 -p <port2>:8081 <image_name> replay <ARCHIVE> <CERTIFICATE> <KEY>
```

Where <URL> is the previously recorded page that is stored in <ARCHIVE>. <port1> and <port2> must free ports. They are used to bind the docker to your local machine and will be used later to redirect HTTP and HTTPS traffic. 
Make sure you use the same <CERTIFICATE> and <KEY> as you did for the record. 

Once Web Page Replay is set in replay mode, you can access the static page from your local machine : 
```
google-chrome --user-data-dir=/tmp/chrome-profil --host-resolver-rules="MAP *:80 127.0.0.1:<port1>,MAP *:443 127.0.0.1:<port2>,EXCLUDE localhost" <URL> 
```


## Disclaimer 

No validation tests are done for the arguments, check the logs in case of a problem. 
