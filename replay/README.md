### Replay

## Used tools 

This docker uses Web Page Replay in replay mode to replay the previously visited pages. 

## Prerequisites 
Having done ```go wpr.go rootinstall etc ``` with the right certificate.  another script?

## How to use this docker 

Build the image using the Dockerfile : 
```
cd record
docker build -t <image_name> .
```


Then run the image on a docker : 
```
docker run --rm -d -v "$(pwd):/workdir" -p <port1>:8080 -p <port2>:8081 <image_name> <ARCHIVE> <CERTIFICATE> <KEY>
```

Where <URL> is the previously recorded page that is stored in <ARCHIVE>. <port1> and <port2> must free ports. They are used to bind the docker to your local machine and will be used later to redirect HTTP and HTTPS traffic. 
Make sure you use the same <CERTIFICATE> and <KEY> as you did for the replay. They can be generated with : 
```
openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
```

Once Web Page Replay is set in replay mode, you can access the static page from your local machine : 
```
google-chrome --user-data-dir=/tmp/chrome-profil --host-resolver-rules="MAP *:80 127.0.0.1:<port1>,MAP *:443 127.0.0.1:<port2>,EXCLUDE localhost" <URL> 
```

## Output 

In the output, you will have : 
- wpr.log : logs of the tool Web Page Replay which is used in recording mode.


No validation tests are done, check the logs if you face a problem. 

## Docker stop 

The Docker is now running in the background, thanks to the detatched mode. It needs to be stopped manually : 
```docker ps``` to get the docker's ID the ```docker stop <ID>``` to stop it. 