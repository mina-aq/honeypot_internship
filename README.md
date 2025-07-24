# RECORD AND REPLAY A PAGE

This repository contains a Dockerfile to build an image that can be used in two modes : to record a website and to replay what was recorded.
Tested only on Ubuntu. 

## Used tools

In record mode, this docker uses Web Page Replay to record the visited sites and saves them in an archive. 
Lynx lists the URLs to visit then sitespeed.io is used to orchestrate Web Page Replay to visit the URLs. 

In replay mode, this docker uses Web Page Replay to replay the previously visited pages. 

#### Documentation : 
* Web Page Replay : https://chromium.googlesource.com/catapult/+/HEAD/web_page_replay_go/README.md 
* sitespeed.io : https://www.sitespeed.io/documentation/sitespeed.io/configuration/ 
* Lynx : https://lynx.invisible-island.net/lynx_help/ 

## Prerequisites 

* You need to install Docker with the right configuration : 
    - https://docs.docker.com/engine/install/ubuntu/
    - https://docs.docker.com/engine/install/linux-postinstall/

* Go with version >= 1.23.0 : 
    - https://go.dev/doc/install

* google-chrome to test the replay 


## Initialize - For generating self-signed certificates (probably not needed)

Before beginning, run : 
```
chmod +x init.sh 
./init.sh 
```

This script will generate a PEM certificate and key. 
To use your own certificate, run :
```
./init.sh <your certificate> <your key>
```


## Build or pull the docker image

You can either pull the image from Docker Hub : 
```
docker pull minaq3/wpr:latest
```

Or you can clone this repository and build your own image :
``` 
docker build -t <image_name> .
```


## Record 

To run the created image : 
```
docker run --rm -v "$(pwd):/workdir" -v "dir/to/certs:/certs" <image_name> record <URL> <DEPTH> <MAX_PAGES> <CERTIFICATE> <KEY>
```
Where ```URL``` is the page you want to record by specifying the crawl depth with ```DEPTH``` and the maximum number of visited pages with ```MAX_PAGES```. 

For ```DEPTH``` = 0, you will only have the given ```URL```. The crawl only keeps the pages of the same domain as the given URL. 


#### Output :

* *archive.wprgo* : archive file of the recorded site. Used for the [replay](#replay).
* *record_logs/wpr.log* : logs of Web Page Replay which is used in recording mode. 
* *record_logs/sitespeed.log* : logs of sitespeed.io which is used to vite the URL you want to record.
* *record_logs/sitespeed.io_output* : output folder of sitespeed.io containing metrics, HAR files, etc... 
* *record_logs/visited_links.txt* : links that are supposed to be recorded in the archive. 


## Replay 

To run the created image : 
```
docker run --rm -d -v "$(pwd):/workdir" -v "dir/to/certs:/certs" -v "dir/to/archive:/archive" -p <port1>:8080 -p <port2>:8081 <image_name> replay <ARCHIVE> <CERTIFICATE> <KEY>
```

Where ```URL``` is the previously recorded page that is stored in ```ARCHIVE```.

 ```port1``` and ```port2``` must free ports. They are used to bind the docker to your local machine and will be used later to redirect HTTP and HTTPS traffic. 
Inside the docker, port 8080 is for HTTP and 8081 for HTTPS.

Make sure you use the same ```CERTIFICATE``` and ```KEY``` as you did for the record if you recorded a HTTPS website. 

Once Web Page Replay is set in replay mode, you can access the static page from your local machine : 
```
google-chrome --user-data-dir=/tmp/chrome-profil --host-resolver-rules="MAP *:80 127.0.0.1:<port1>,MAP *:443 127.0.0.1:<port2>,EXCLUDE localhost" <URL> 
```

Stop the replay by stopping the container : 
``` 
docker stop <docker name>
```

#### Output : 

* *replay_logs/wpr.log*

## Reverse proxy - Nginx

Here is an example of configuration for a reverse proxy with nginx :

* Let's say you have 2 HTTP servers running : 
    - ```docker run --rm -d -v "$(pwd):/workdir" -v "dir/to/certs:/certs" -v "dir/to/archive:/archive" -p 8080:8080  <image_name> replay <ARCHIVE> <CERTIFICATE> <KEY>```
    - ```docker run --rm -d -v "$(pwd):/workdir" -v "dir/to/certs:/certs" -v "dir/to/archive:/archive" -p 8081:8080  <image_name> replay <ARCHIVE> <CERTIFICATE> <KEY>```
* If you have installed nginx from apt package, your configuration files are located in /etc/nginx/. Create a file in /etc/nginx/sites-available/ for each server and add the following blocs : 

    - */etc/nginx/sites-available/server1*
        ```
        server {
            listen 80;
            server_name <server1>;

            location / {
                proxy_pass http://localhost:8081/;
                proxy_set_header Host <wpr_domain>;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        }
        ```

    - */etc/nginx/sites-available/server2*

        ```
        server {
            listen 80;
            server_name <server2>;

            location / {
                proxy_pass http://localhost:8080/;
                proxy_set_header Host <wpr_domain>;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        }
        ```
    The directive ```server_name``` defines how you want the server to be accessed. E.g. : ```server_name myserver.mine.com```. Ensure that this name is correctly resolved by the client's machine, either by changing /etc/hosts or by configuring the local DNS resolver.

    The directive ```proxy_set_header Host``` should match the domain name used during the recording phase. 

* Restart your reverse proxy ```sudo systemctl restart nginx.service```.
* Now you can access both your servers from a browser by typing in a browser ```http://server1``` and ```http://server2```. 

For more information on the configuration, check the documentation : https://nginx.org/en/docs/. 


## Disclaimer 

No validation tests are done for the arguments. Check the logs in case of a problem. 
