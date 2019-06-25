ARG DEBIAN
FROM debian:${DEBIAN}

RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y \
          dnsutils \
          iputils-ping \
          iputils-tracepath \
          nmap \
          tcptraceroute \
          telnet \
          traceroute \
      && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
