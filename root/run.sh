#! /bin/sh

#
# Set root password and start CUPS instance
#

### Enable debug if debug flag is true ###
if [ -n "${CUPS_ENV_DEBUG}" ]; then
  set -ex
fi

### Error handling ###
error_handling() {
  if [ "${RETURN}" -eq 0 ]; then
    echo "${SCRIPT} successfull!"
  else
    echo "${SCRIPT} aborted, reason: ${REASON}"
  fi
  exit "${RETURN}"
}
trap "error_handling" EXIT HUP INT QUIT TERM
RETURN=0
REASON="Finished!"

### Default values ###
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C
export LANG=C
SCRIPT=$(basename ${0})

### Check prerequisite ###
if [ ! -f /.dockerenv ]; then RETURN=1; REASON="Not executed inside a Docker container, aborting!"; exit; fi
if [ ! -d /opt/cups ]; then RETURN=1; REASON="CUPS configuration dirctory not found, aborting!"; exit; fi

### Prepare avahi-daemon configuration ###
sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf
sed -i 's/.*enable\-reflector=.*/enable\-reflector\=yes/' /etc/avahi/avahi-daemon.conf
sed -i 's/.*reflect\-ipv=.*/reflect\-ipv\=yes/' /etc/avahi/avahi-daemon.conf

### Copy CUPS docker env variable to script ###
CUPS_PASSWORD=${CUPS_ENV_PASSWORD:-"password"}

### Main logic to create an admin user for CUPS ###
if printf '%s' "${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  RETURN=1; REASON="CUPS password contain illegal non-ASCII characters, aborting!"; exit;
fi

### Set password for root user ###
echo root:${CUPS_PASSWORD} | /usr/sbin/chpasswd
if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to set password ${CUPS_PASSWORD} for user root, aborting!"; exit; fi

cat <<EOF

===========================================================

The dockerized CUPS instance is now ready for use! The web
interface is available here:

URL:       https://${CUPS_ENV_HOST}:631/
Username:  root
Password:  ${CUPS_PASSWORD}

===========================================================

EOF

### Start syslogd ###
/sbin/syslogd

### Start automatic printer refresh for avahi ###
autorefresh() {
  test -d /etc/cups || return 1
  /usr/bin/inotifywait -m -e close_write,moved_to,create /etc/cups |
    while read -r directory events filename; do
      if [ "$filename" = "printers.conf" ]; then
        rm -rf /services/AirPrint-*.service
        /root/airprint-generate.py -d /services
        cp /etc/cups/printers.conf /config/printers.conf
        rsync -avh /services/ /etc/avahi/services/
      fi
    done
}
# autorefresh &

### Start avahi instance ###
/usr/sbin/avahi-daemon --daemonize --syslog

### Start CUPS instance ###
/usr/sbin/cupsd -f -c /etc/cups/cupsd.conf
