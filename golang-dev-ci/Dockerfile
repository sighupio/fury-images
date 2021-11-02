ARG GOLANG_VERSION

FROM golang:${GOLANG_VERSION}-alpine3.14

ENV CGO_ENABLED=0
ENV GOARCH=amd64
ENV GOMAXPROCS=1
ENV GOOS=linux
ENV GOPRIVATE=github.com/sighupio/*

RUN go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/swaggo/swag/cmd/swag@latest && \
    go install mvdan.cc/gofumpt@latest && \
    go install github.com/google/addlicense@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest