FROM alpine:latest

# Adding Aws-cli to be able to upload snapshot to S3
RUN apk add --update --no-cache curl python py-pip
RUN pip install --upgrade pip && pip install awscli --upgrade && aws --version

# Adding ETCDCTL to create database snapshot
ARG GOOGLE_URL=https://storage.googleapis.com/etcd
# ARG GITHUB_URL=https://github.com/coreos/etcd/releases/download
ARG ETCD_VER=v3.3.5
ENV ETCDCTL_API=3
RUN mkdir -p /tmp/etcd-download-test && \
    curl -L ${GOOGLE_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1 && \
    mv /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl && \
    chmod +x /usr/local/bin/etcdctl && \
    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    rm -fr /tmp/etcd-download-test && \
    etcdctl version

ADD entrypoint.sh /entrypoint.sh
RUN mkdir -p /backup && chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]