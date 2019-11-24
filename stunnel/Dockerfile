FROM debian:stretch-slim

ARG STUNNEL_VERSION

RUN set -x && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
      libssl-dev \
      cron \
      procps \
      wget && \
    wget ftp://ftp.stunnel.org/stunnel/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz && \
    tar -xzf stunnel-${STUNNEL_VERSION}.tar.gz && \
    cd stunnel-${STUNNEL_VERSION} && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf stunnel-${STUNNEL_VERSION} stunnel-${STUNNEL_VERSION}.tar.gz && \
    # DEBIAN_FRONTEND=noninteractive apt-get purge -y build-essential \
    #   libssl-dev \
    #   wget && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/sh", "-c", "service cron start && stunnel"]
