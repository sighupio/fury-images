ARG ALPINE
FROM alpine:${ALPINE}

ARG ETCD_VER=v3.5.19

RUN apk add curl yq

RUN mkdir /tmp/etcd-download-test

RUN curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1 && \
    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    mv /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl && \
    etcdctl version

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]

