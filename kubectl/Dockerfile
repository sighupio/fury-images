FROM alpine:latest

RUN apk add curl --no-cache --update
ARG KUBECTL=v1.11.2
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
ENTRYPOINT [ "/usr/local/bin/kubectl" ]
