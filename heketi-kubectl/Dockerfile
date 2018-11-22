ARG HEKETI_VERSION=7
FROM heketi/heketi:${HEKETI_VERSION}
ARG KUBECTL_VERSION=1.11.0
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl