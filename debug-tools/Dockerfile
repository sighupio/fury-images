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
          wget \
      && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

CMD ["sleep", "infinity"]
