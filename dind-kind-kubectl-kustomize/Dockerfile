ARG DOCKER_VERSION=20.10.14
ARG ALPINE_VERSION=3.15
ARG KIND_VERSION=0.12.0
ARG KUBECTL_VERSION=1.23.0
ARG KUSTOMIZE_VERSION=3.10.0

FROM docker:${DOCKER_VERSION}-dind-alpine${ALPINE_VERSION}

RUN apk add bash curl git jq make util-linux \
    wget -qO /usr/local/bin/kind "https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-$(uname)-amd64" \
    wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    wget -q -O - https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash -s ${KUSTOMIZE_VERSION} /usr/local/bin \
    chmod +x /usr/local/bin/kind /usr/local/bin/kubectl
