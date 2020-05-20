FROM golang:alpine as builder
ARG DRONE
RUN mkdir /build
ADD . /build/
WORKDIR /build
RUN apk add git build-base
RUN git clone https://github.com/drone/drone.git
WORKDIR /build/drone
RUN git checkout v${DRONE}
RUN go build -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM drone/drone:${DRONE}
RUN rm /bin/drone-server
COPY --from=builder /build/drone/drone-server /bin/drone-server