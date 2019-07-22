ARG UBUNTU
FROM ubuntu:${UBUNTU}

RUN apt update && apt install -y curl unzip software-properties-common ansible git-crypt gnupg2

ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

ARG KUSTOMIZE
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    kustomize version

ARG TERRAFORM
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin && \
    rm terraform.zip && \
    chmod +x /usr/local/bin/terraform && \
    terraform version

VOLUME /.gnupg/
