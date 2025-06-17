## How to use this docker 

First, you need to clone this repository : 
bash```
git clone blah blah 
```

Build the image using the Dockerfile : 
bash```
cd record
docker build -t <image_name> .
```


Then run the image on a docker : 
bash```
docker run --rm -v "$(pwd):/workdir" <image_name> <URL> <DEPTH>
```

Where <URL> is the page you want to record by specifying the crawl depth with <DEPTH>


In the output, you will have : 
- archive.wprgo : archive file of the recorded site. Used for the replay [insert link to replay page]
- wpr.log : logs of the tool Web Page Replay which is used in recording mode.
- sitespeed.log : logs of the tool sitespeed.io which is used to vite the URL you want to record.
- sitespeed.io_output : output folder of sitespeed.io containing metrics, HAR files, etc... 


No validation test are done, check the logs if you face a problem. 