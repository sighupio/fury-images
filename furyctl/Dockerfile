FROM alpine:3.11

RUN apk add git openssh curl

ARG FURYCTL

RUN curl -Ls https://github.com/sighupio/furyctl/releases/download/${FURYCTL}/furyctl-linux-amd64 -o furyctl \
	&& chmod +x furyctl && mv furyctl /usr/local/bin
