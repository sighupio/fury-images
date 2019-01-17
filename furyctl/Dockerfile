ARG ALPINE
FROM alpine:${ALPINE}
ARG FURYCTL
RUN wget https://s3.wasabisys.com/sighup-releases/linux/${FURYCTL}/furyctl \
	&& chmod +x furyctl && mv furyctl /usr/local/bin && apk add git openssh
