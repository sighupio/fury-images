FROM alpine:3.16

LABEL maintainer="engineering@sighup.io"

ENV ARCH=amd64
ENV ARCH_ALT=x86_64
ENV AWSCLI_VERSION 1.19
ENV GCLOUD_VERSION 344.0.0
ENV TERRAFORM_VERSION 1.0.1
ENV KUBECTL_VERSION v1.21.2
ENV KUSTOMIZE_VERSION v3.6.1
ENV FURYCTL_VERSION v0.8.0-rc1
ENV FURYAGENT_VERSION v0.2.3
ENV VELERO_VERSION v1.6.0
ENV DIRENV_VERSION v2.28.0
ENV YQ_VERSION v4.14.1
ENV GIT_CRYPT=0.6.0

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
  nano \
  make \
  tree \
  bind-tools \
  bash-completion \
  ansible

RUN apk add g++ make openssl openssl-dev --no-cache --update && \
    curl -L https://github.com/AGWA/git-crypt/archive/${GIT_CRYPT}.tar.gz | tar zxv -C /var/tmp  && \
    cd /var/tmp/git-crypt-${GIT_CRYPT} && make && make install && \
    rm -r /var/tmp/git-crypt-${GIT_CRYPT}

RUN pip3 install --upgrade pip
RUN pip3 install requests awscli==${AWSCLI_VERSION}

# Install gcloud
RUN curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH_ALT}.tar.gz -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH_ALT}.tar.gz && \
    mkdir -p /usr/local/gcloud && \
    tar -zxf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH_ALT}.tar.gz -C /usr/local/gcloud/ && \
    rm /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-${ARCH_ALT}.tar.gz

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install Terraform
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip -o /tmp/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz -o /tmp/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    tar -zxf /tmp/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz -C /usr/local/bin/ && \
    rm /tmp/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# Install furyctl
RUN curl -L https://github.com/sighupio/furyctl/releases/download/${FURYCTL_VERSION}/furyctl-linux-${ARCH} -o /usr/local/bin/furyctl && \
  chmod +x /usr/local/bin/furyctl

# Install furyagent
RUN curl -L https://github.com/sighupio/furyagent/releases/download/${FURYAGENT_VERSION}/furyagent-linux-${ARCH} -o /usr/local/bin/furyagent && \
  chmod +x /usr/local/bin/furyagent

# Install velero cli
RUN curl -L https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz -o /tmp/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz && \
    tar -zxf /tmp/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz -C /tmp/ && \
    mv /tmp/velero-${VELERO_VERSION}-linux-${ARCH}/velero /usr/local/bin && \
    rm /tmp/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz && rm -rf /tmp/velero-${VELERO_VERSION}-linux-${ARCH}

# Install direnv
RUN curl -L https://github.com/direnv/direnv/releases/download/${DIRENV_VERSION}/direnv.linux-${ARCH} -o /usr/local/bin/direnv && \
  chmod +x /usr/local/bin/direnv

# Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH} -o /usr/bin/yq && chmod +x /usr/bin/yq

# Create a group and user
RUN mkdir -p /workdir

# Clone repository

# Add create command
COPY src/create.sh /create.sh
RUN chmod +x /create.sh

# Add destroy command
COPY src/destroy.sh /destroy.sh
RUN chmod +x /destroy.sh

WORKDIR /workdir

# Create cluster
ENTRYPOINT ["/create.sh"]

# To delete cluster use:
# ENTRYPOINT ["/destroy.sh"]
