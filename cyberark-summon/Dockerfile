FROM debian:buster

ARG SUMMON
ARG SUMMON_CONJUR

WORKDIR /summon

RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y curl && \
      curl -L https://github.com/cyberark/summon-conjur/releases/download/v${SUMMON_CONJUR}/summon-conjur-linux-amd64.tar.gz -O && \
      curl -L https://github.com/cyberark/summon/releases/download/v${SUMMON}/summon-linux-amd64.tar.gz -O && \
      mkdir -p /usr/local/lib/summon && \
      tar -xzvf /summon/summon-conjur-linux-amd64.tar.gz -C /usr/local/lib/summon && \
      tar -xzvf /summon/summon-linux-amd64.tar.gz -C /usr/local/bin && \
      chmod +x /usr/local/lib/summon/summon-conjur /usr/local/bin/summon && \
      rm -rf /summon/* /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
