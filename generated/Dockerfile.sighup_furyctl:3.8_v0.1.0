FROM alpine:3.8
RUN wget https://s3.wasabisys.com/sighup-releases/linux/v0.1.0/furyctl \
	&& chmod +x furyctl && mv furyctl /usr/local/bin && apk add git openssh
