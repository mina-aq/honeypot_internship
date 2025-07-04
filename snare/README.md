docker run --rm -v "$(pwd):/workdir" <image_name> <URL> <DEPTH> 

docker run --rm -v "$(pwd):/workdir" -p 8080:8080 snare:latest grafana.com 1

docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKER_HOST=unix:///var/run/docker.sock \
  -p 8080:8080 \
  <ton-image>
