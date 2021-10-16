#! /bin/sh

#
# Start docker image that provides a CUPS instance
#

### Set standard password if not set with local environment variable ###
if [ -n "${CUPS_PASSWORD}" ]; then
  CUPS_PASSWORD=password
fi

### Run docker instance ###
docker run --detach --restart always \
  --cap-add=SYS_ADMIN \
  -e "container=docker" \
  -e CUPS_ENV_HOST="$(hostname -f)" \
  -e CUPS_ENV_PASSWORD="${CUPS_PASSWORD}" \
  -e CUPS_ENV_DEBUG="${CUPS_DEBUG}" \
  -p 137:137/udp -p 139:139/tcp -p 445:445/tcp \
  -p 631:631/tcp -p 5353:5353/udp \
  --hostname cups.$(hostname -f | sed -e 's/^[^.]*\.//') \
  --name cups \
  thbe/cups
