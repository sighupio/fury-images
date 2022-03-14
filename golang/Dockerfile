ARG GOLANG_VERSION=1.17.6
ARG ALPINE_VERSION=3.15

FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION}

ARG GOARCH=amd64

ARG ADDLICENSE_VERSION=v1.0.0
ARG DLV_VERSION=v1.8.0
ARG GOCLEANARCH_VERSION=v1.2.1
ARG GOFUMPT_VERSION=v0.2.1
ARG GOIMPORTS_VERSION=v0.1.8
ARG GOLANGCILINT_VERSION=v1.43.0
ARG MAGE_VERSION=v1.12.1
ARG GOMIGRATE_VERSION=v4.15.1

ENV CGO_ENABLED=0
ENV GOARCH=${GOARCH}
ENV GOMAXPROCS=1
ENV GOOS=linux
ENV GOPRIVATE=github.com/sighupio/*

RUN apk update && \
    apk add bash git jq make util-linux

RUN go install github.com/go-delve/delve/cmd/dlv@${DLV_VERSION} && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCILINT_VERSION} && \
    go install github.com/google/addlicense@${ADDLICENSE_VERSION} && \
    go install github.com/roblaszczak/go-cleanarch@${GOCLEANARCH_VERSION} && \
    go install golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION} && \
    go install mvdan.cc/gofumpt@${GOFUMPT_VERSION} && \
    go install github.com/magefile/mage@${MAGE_VERSION} && \
    go install github.com/golang-migrate/migrate/v4@${GOMIGRATE_VERSION}
