FROM alpine:3.10

ARG AWSCLI
ARG TERRAFORM
ARG KUBECTL
ARG KUSTOMIZE
ARG FURYCTL
ARG FURYAGENT

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

RUN pip3 install --upgrade pip
RUN pip3 install requests awscli==${AWSCLI}

# Install Terraform
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip -o /tmp/terraform_${TERRAFORM}_linux_amd64.zip && \
    unzip /tmp/terraform_${TERRAFORM}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM}_linux_amd64.zip

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE}/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz -o /tmp/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    tar -zxf /tmp/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz -C /usr/local/bin/ && \
    rm /tmp/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz

# Install furyctl
RUN curl -L https://github.com/sighupio/furyctl/releases/download/v${FURYCTL}/furyctl-linux-amd64 -o /usr/local/bin/furyctl && \
  chmod +x /usr/local/bin/furyctl

# Install furyagent
RUN curl -L https://github.com/sighupio/furyagent/releases/download/v${FURYAGENT}/furyagent-linux-amd64 -o /usr/local/bin/furyagent && \
  chmod +x /usr/local/bin/furyagent

WORKDIR /demo

CMD ["/bin/bash"]
