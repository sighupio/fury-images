ARG UBUNTU=20.04
FROM ubuntu:${UBUNTU}

ARG KUBECTL=v1.20.1
ARG FURYAGENT=v0.2.2
ARG BATS=v1.2.1

ENV DEBIAN_FRONTEND=noninteractive

COPY vpn-connect.sh /bin/vpn-connect
COPY vpn-disconnect.sh /bin/vpn-disconnect

RUN apt-get update && apt-get install -yqq curl ca-certificates gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get upgrade -yq && \
    apt-get dist-upgrade -yq && \
    apt-get autoclean -yq && \
    apt-get autoremove -yq && \
    apt-get install -yqq openvpn inetutils-ping netcat dnsutils git gettext google-cloud-sdk unzip && \
    curl -Ls https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    curl -Ls https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    curl -Ls https://github.com/sighupio/furyagent/releases/download/${FURYAGENT}/furyagent-linux-amd64 -o /usr/local/bin/furyagent && \
    git clone --depth 1 --branch ${BATS} https://github.com/bats-core/bats-core.git && ./bats-core/install.sh /usr/local && \
    rm -rf ./bats-core && \
    chmod +x /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/furyagent && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ./aws ./awscliv2.zip


# Remember to run this container image with --cap-add=NET_ADMIN
# Otherwise the VPN connection will not work
