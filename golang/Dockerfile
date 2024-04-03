ARG GOLANG_VERSION=1.22.1
ARG ALPINE_VERSION=3.19

FROM --platform=${BUILDPLATFORM} golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION}

ARG TARGETOS TARGETARCH

ARG ADDLICENSE_VERSION=v1.1.1
ARG DLV_VERSION=v1.22.1
ARG GINGKO_VERSION=v2.16.0
ARG GOFUMPT_VERSION=v0.6.0
ARG GOIMPORTS_VERSION=v0.19.0
ARG GOLANGCILINT_VERSION=v1.57.2
ARG GOMIGRATE_VERSION=v4.17.0
ARG GORELEASER_VERSION=v1.24.0
ARG GOVULNCHECK_VERSION=v1.0.4
ARG JSON_PATCH_VERSION=v4.12.0

ENV CGO_ENABLED=0
ENV GOARCH=${TARGETARCH}
ENV GOOS=${TARGETOS}
ENV GOPRIVATE=github.com/sighupio/*
ENV PATH=/go/bin/${TARGETOS}_${TARGETARCH}:${PATH}

RUN apk update && \
    apk add build-base curl git jq make util-linux yq docker-cli docker-cli-buildx cosign

RUN go install github.com/google/addlicense@${ADDLICENSE_VERSION} && \
    go install github.com/go-delve/delve/cmd/dlv@${DLV_VERSION} && \
    go install github.com/onsi/ginkgo/v2/ginkgo@${GINGKO_VERSION} && \
    go install mvdan.cc/gofumpt@${GOFUMPT_VERSION} && \
    go install golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION} && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCILINT_VERSION} && \
    go install github.com/golang-migrate/migrate/v4/cmd/migrate@${GOMIGRATE_VERSION} && \
    go install github.com/goreleaser/goreleaser@${GORELEASER_VERSION} && \
    go install golang.org/x/vuln/cmd/govulncheck@${GOVULNCHECK_VERSION} && \
    go install github.com/evanphx/json-patch/cmd/json-patch@${JSON_PATCH_VERSION}
