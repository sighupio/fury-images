ARG VERSION

FROM golang:1.21.6-alpine3.18 as builder

RUN mkdir /build
ADD . /build/

WORKDIR /build
RUN apk add git build-base && \
    git clone https://github.com/harness/gitness.git

WORKDIR /build/gitness
ARG VERSION

RUN git checkout v${VERSION}
RUN go build -tags "nolimit" github.com/drone/drone/cmd/drone-server


FROM drone/drone:${VERSION}

RUN rm /bin/drone-server

COPY --from=builder /build/drone/drone-server /bin/drone-server
