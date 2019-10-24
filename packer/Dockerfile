ARG DEBIAN

FROM debian:${DEBIAN}

ARG ANSIBLE
ARG PACKER

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev wget jq git ca-certificates openssh-client sed openssl unzip \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip \
  && pip install ansible==${ANSIBLE}

RUN cd /tmp \
  && wget -O /tmp/packer.zip \
    "https://releases.hashicorp.com/packer/${PACKER}/packer_${PACKER}_linux_amd64.zip" \
  && unzip -o /tmp/packer.zip -d /usr/local/bin \
  && rm -f /tmp/packer.zip \
  && groupadd -r packer && useradd -r -m -g packer packer

USER packer
