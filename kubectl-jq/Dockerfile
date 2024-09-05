FROM alpine:3.20

RUN apk add curl ca-certificates jq --no-cache --update
ARG KUBECTL
RUN curl -L "https://dl.k8s.io/release/v${KUBECTL}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  kubectl version --client
