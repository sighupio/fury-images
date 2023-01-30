ARG DRONE

FROM golang:1.19.5-alpine as builder

RUN mkdir /build
ADD . /build/

WORKDIR /build
RUN apk add git build-base && \
    git clone https://github.com/harness/drone.git

WORKDIR /build/drone
RUN git checkout v${DRONE}
RUN go build -tags "nolimit" github.com/harness/drone/cmd/drone-server

ARG DRONE

FROM drone/drone:${DRONE}

RUN rm /bin/drone-server

COPY --from=builder /build/drone/drone-server /bin/drone-server
