ARG DEBIAN
FROM debian:${DEBIAN}

RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y \
          curl \
          dnsutils \
          iputils-ping \
          iputils-tracepath \
          jq \
          netcat-traditional \
          nmap \
          tcptraceroute \
          telnet \
          traceroute \
          fio \
      && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
