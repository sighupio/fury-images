FROM ubuntu:20.04

ARG KUBECTL
ARG HELM
ARG YQ
ARG ISTIOCTL
ARG FURYCTL
ARG KUSTOMIZE
ARG BATS

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -yq && apt-get autoclean -yq && \
    apt-get autoremove -yq

RUN apt-get install -yq make git curl ca-certificates npm jq

RUN npm install -g bats@${BATS}

RUN curl -LOs https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN curl -LOs https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz && \
    tar -zxvf helm-v${HELM}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64/

RUN curl -LOs https://github.com/mikefarah/yq/releases/download/${YQ}/yq_linux_amd64 && \
    chmod +x yq_linux_amd64 && \
    mv yq_linux_amd64 /usr/local/bin/yq

RUN curl -LOs https://github.com/istio/istio/releases/download/${ISTIOCTL}/istioctl-${ISTIOCTL}-linux-amd64.tar.gz && \
    tar -zxvf istioctl-${ISTIOCTL}-linux-amd64.tar.gz && \
    chmod +x istioctl && \
    mv istioctl /usr/local/bin/istioctl

RUN curl -LOs https://github.com/sighupio/furyctl/releases/download/v${FURYCTL}/furyctl-linux-amd64 && \
    chmod +x furyctl-linux-amd64 && \
    mv furyctl-linux-amd64 /usr/local/bin/furyctl

RUN curl -LOs https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    tar -zxvf kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

RUN make --version && \
    kubectl version --client && \
    helm version --client && \
    jq --version && \
    yq --version && \
    istioctl version --remote=false && \
    furyctl version && \
    kustomize version && \
    bats --version
