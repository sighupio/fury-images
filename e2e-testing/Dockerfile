FROM ubuntu:22.04

ARG KUBECTL
ARG HELM
ARG YQ
ARG KUSTOMIZE
ARG BATS
ARG DEBIAN_FRONTEND=noninteractive

ENV PATH /root/go/bin:/usr/lib/go-1.18/bin:$PATH

RUN apt-get update

RUN apt-get install -yq make git curl ca-certificates npm jq skopeo

RUN npm install -g bats@${BATS}

RUN curl -fLOs https://dl.k8s.io/release/v${KUBECTL}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN curl -fLOs https://github.com/mikefarah/yq/releases/download/v${YQ}/yq_linux_amd64 && \
    chmod +x yq_linux_amd64 && \
    mv yq_linux_amd64 /usr/local/bin/yq

RUN curl -fLOs https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    tar -zxvf kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

RUN make --version && \
    kubectl version --client && \
    jq --version && \
    yq --version && \
    kustomize version && \
    bats --version
