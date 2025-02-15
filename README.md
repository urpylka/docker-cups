# docker-cups

[![Build Status](https://img.shields.io/docker/automated/thbe/cups.svg)](https://hub.docker.com/r/thbe/cups/builds/) [![GitHub Stars](https://img.shields.io/github/stars/thbe/docker-cups.svg)](https://github.com/thbe/docker-cups/stargazers) [![Docker Stars](https://img.shields.io/docker/stars/thbe/cups.svg)](https://hub.docker.com/r/thbe/cups) [![Docker Pulls](https://img.shields.io/docker/pulls/thbe/cups.svg)](https://hub.docker.com/r/thbe/cups)

This is a Docker image to run a CUPS instance with built in Apple's zeroconf support.

This Docker image is based on:

* The offical [Alpine](https://hub.docker.com/r/_/alpine/) image;
* CUPS binary from official Alpine package repository.

## Quick start

```bash
export CUPS_PASSWORD='SeCre!1'

docker run --detach --restart always \
  --cap-add=SYS_ADMIN \
  -e "container=docker" \
  -e CUPS_ENV_HOST="$(hostname -f)" \
  -e CUPS_ENV_PASSWORD="${CUPS_PASSWORD}" \
  -p 137:137/udp -p 139:139/tcp -p 445:445/tcp \
  -p 631:631/tcp \
  -p 5353:5353/udp \
  --hostname cups.$(hostname -f | sed -e 's/^[^.]*\.//') \
  --name cups \
  thbe/cups:latest
```

You can use two environment variables that will be recognized by the start script:

1. `CUPS_ENV_DEBUG` with any value, if you wanna see additional output of `run.sh`.
2. The username for the print server is `root`/`password` unless you don't change the password with the environment
variable `CUPS_ENV_PASSWORD`.

After running the container you can find web-interface at port 631.

> Ports 137, 139, 445 are used by Samba protocol; port 5353 is used by zeroconf (avahi-daemon). You can disable it if you want.

Keep in a mind that it use the image from [dockerhub](https://hub.docker.com/r/thbe/cups/). If you want to use own image – build [source code](https://github.com/thbe/docker-cups#build-from-source-code) and tag it.

## Build from source code

You can build the image also from source. To do this you have to clone the
[docker-cups](https://github.com/thbe/docker-cups) repository from GitHub:

```bash
git clone https://github.com/thbe/docker-cups.git
cd docker-cups
docker build --rm --no-cache -t thbe/cups:latest .
```

## Additional commands

```bash
# Check server status
docker logs --tail 1000 --follow --timestamps cups

# Update Docker image
docker pull thbe/cups:latest

# Bash shell inside container
docker exec -ti cups /bin/sh

# Add network tools
docker exec -ti cups /bin/sh
apk update
apk add iputils iproute2
```

___

© 2021 Artem Smirnov \
© 2017-2019 Thomas Bendler \
Licensed under GPL-3.0 License
