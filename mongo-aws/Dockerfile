ARG MONGO
FROM mongo:${MONGO}

RUN apt-get update && apt-get install curl python-pip -y
RUN pip install --user awscli --upgrade && aws --version

ADD entrypoint.sh /entrypoint.sh
RUN mkdir -p /backup && chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
