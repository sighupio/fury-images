ARG UBUNTU
FROM ubuntu:${UBUNTU}

ENV CPUS=2
ENV WORKER=1
ENV MEMORY=1G
ENV TIMEOUT=240s

RUN apt-get update && apt-get install stress-ng -y
ADD entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]