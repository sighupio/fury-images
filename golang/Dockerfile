ARG GOLANG_VERSION=1.17.6
ARG ALPINE_VERSION=3.15
ARG GOFUMPT_VERSION=v0.2.1
ARG GOLANGCILINT_VERSION=v1.43.0
ARG GOIMPORTS_VERSION=v0.1.8
ARG ADDLICENSE_VERSION=v1.0.0
ARG DLV_VERSION=v1.8.0

FROM golang:${GOLANG_VERSION}-${ALPINE_VERSION}

ENV CGO_ENABLED=0
ENV GOARCH=amd64
ENV GOMAXPROCS=1
ENV GOOS=linux
ENV GOPRIVATE=github.com/sighupio/*

RUN apk update && \
    apk add git jq make

RUN go install github.com/go-delve/delve/cmd/dlv@${DLV_VERSION} && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCILINT_VERSION} && \
    go install github.com/google/addlicense@${ADDLICENSE_VERSION} && \
    go install golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION} && \
    go install mvdan.cc/gofumpt@${GOFUMPT_VERSION}
