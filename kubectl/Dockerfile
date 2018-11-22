FROM alpine:latest

RUN apk add curl --no-cache --update
ARG KUBECTL_VERSION=1.11.2
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
ENTRYPOINT [ "/usr/local/bin/kubectl" ]
