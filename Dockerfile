FROM alpine

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>"
LABEL version="1.3"
LABEL description="Creates an Alpine container serving a CUPS instance accessible through airplay as well"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Set workdir
WORKDIR /opt/cups

# Install CUPS/AVAHI
RUN apk update --no-cache && apk add --no-cache \
    cups \
    cups-filters \
    avahi \
    inotify-tools

# Expose SMB printer sharing
EXPOSE 137/udp 139/tcp 445/tcp

# Expose IPP printer sharing
EXPOSE 631/tcp

# Expose avahi advertisement
EXPOSE 5353/udp

# Copy configuration files
COPY root /

# Prepare CUPS container
RUN chmod 755 /srv/run.sh

# Start CUPS instance
CMD ["/srv/run.sh"]
