FROM alpine:3.9

RUN apk add curl ca-certificates --no-cache --update
ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

ARG KUSTOMIZE
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    kustomize version
