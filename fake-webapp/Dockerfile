# syntax=docker/dockerfile:1

##
## Build
##
FROM golang:1.17.8-buster AS build

WORKDIR /app

COPY src/* ./

RUN go mod download && go build -o /fake-webapp

##
## Deploy
##
FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /fake-webapp /fake-webapp

USER nonroot:nonroot

ENTRYPOINT ["/fake-webapp"]
