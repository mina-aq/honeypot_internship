### Record 

## Used tools 

This docker uses Web Page Replay in record mode to record the visited sites and saves them in an archive.
The tool sitespeed.io is also used as a crawler to orchestrate Web Page Replay to visit the site and its subpages. 
The archive saved by Web Page Replay can be replayed, in static mode. 

## How to use this docker 

Build the image using the Dockerfile : 
```
docker build -t <image_name> .
```


Then run the image on a docker : 
```
docker run --rm -v "$(pwd):/workdir" <image_name> <URL> <DEPTH> <CERTIFICATE> <KEY>
```

Where <URL> is the page you want to record by specifying the crawl depth with <DEPTH>. 
<CERTIFICATE> and <KEY> can be generated with : 
```
openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
```


In the output, you will have : 
- archive.wprgo : archive file of the recorded site. Used for the replay [insert link to replay page]
- wpr.log : logs of the tool Web Page Replay which is used in recording mode.
- sitespeed.log : logs of the tool sitespeed.io which is used to vite the URL you want to record.
- sitespeed.io_output : output folder of sitespeed.io containing metrics, HAR files, etc... 


No validation tests are done, check the logs if you face a problem. 