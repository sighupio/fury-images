FROM golang:1.11-alpine as builder

ARG MONGODB_EXPORTER

RUN apk add --no-cache git \
     && go get github.com/percona/mongodb_exporter

FROM alpine:3.10

COPY --from=builder /go/bin/mongodb_exporter /usr/bin/mongodb_exporter

EXPOSE 9216

ENTRYPOINT [ "mongodb_exporter" ]
