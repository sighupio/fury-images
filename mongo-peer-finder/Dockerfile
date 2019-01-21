ARG MONGO
FROM mongo:${MONGO}

ENV PEER_FINDER_DOWNLOAD_URL https://storage.googleapis.com/kubernetes-release/pets/peer-finder
ENV PEER_FINDER_DOWNLOAD_SHA 230e96b4e6ae962c465b86553e2b4ccbc989efc6da7b2a93520f4f97a87e8e1c

RUN set -eux \
      && apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
      && curl -fsSL -o /usr/bin/peer-finder "${PEER_FINDER_DOWNLOAD_URL}" \
      && echo "${PEER_FINDER_DOWNLOAD_SHA} */usr/bin/peer-finder" | sha256sum -c - \
      && chmod +x /usr/bin/peer-finder \
      && DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove curl \
      && rm -rf /var/lib/apt/lists/*
