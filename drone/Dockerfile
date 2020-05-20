FROM golang:alpine as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build
RUN apk add git build-base
RUN git clone https://github.com/drone/drone.git
WORKDIR /build/drone
RUN git checkout v1.7.0
RUN go build -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM drone/drone:1.7.0
RUN rm /bin/drone-server
COPY --from=builder /build/drone/drone-server /bin/drone-server