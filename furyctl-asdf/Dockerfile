FROM alpine:3.10

ARG ASDF=0.8.1
ARG FURYCTL=0.5.0
ARG FURYAGENT=0.2.3

ENV PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin:/root/.asdf/shims"

RUN apk --update --no-cache add \
  bash \
  ca-certificates \
  curl \
  jq \
  git \
  openssh-client \
  python3 \
  py3-pip \
  openvpn \
  tar \
  wget \
  vim \
  make \
  tree \
  bind-tools

# Python backward compatibility
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install furyctl
RUN curl -L https://github.com/sighupio/furyctl/releases/download/v${FURYCTL}/furyctl-linux-amd64 -o /usr/local/bin/furyctl && \
  chmod +x /usr/local/bin/furyctl

# Install furyagent
RUN curl -L https://github.com/sighupio/furyagent/releases/download/v${FURYAGENT}/furyagent-linux-amd64 -o /usr/local/bin/furyagent && \
  chmod +x /usr/local/bin/furyagent

WORKDIR /asdf

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git /asdf/.asdf --branch v${ASDF}

# Terraform
RUN asdf plugin add terraform
RUN asdf install terraform 0.15.0
RUN asdf global terraform 0.15.0

# Kustomize
RUN asdf plugin add kustomize
RUN asdf install kustomize 3.6.1
RUN asdf global kustomize 3.6.1

# Kubectl
RUN asdf plugin add kubectl
RUN asdf install kubectl 1.19.2
RUN asdf global kubectl 1.19.2

# Kubectx
RUN asdf plugin add kubectx
RUN asdf install kubectx 0.9.3
RUN asdf global kubectx 0.9.3

# AWS CLI
RUN asdf plugin add awscli
RUN asdf install awscli 1.19.0
RUN asdf global awscli 1.19.0

# Google CLI
RUN asdf plugin add gcloud
RUN asdf install gcloud 344.0.0
RUN asdf global gcloud 344.0.0

# Velero
RUN asdf plugin add velero
RUN asdf install velero v1.6.0
RUN asdf global velero v1.6.0

WORKDIR /delivery

CMD ["/bin/bash"]
