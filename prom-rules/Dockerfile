ARG ALPINE
FROM alpine:${ALPINE}
ARG FURYCTL
ARG YQ
ARG PROMETHEUS
RUN apk add --no-cache --update ca-certificates curl bash
RUN curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ}/yq_linux_amd64 && chmod +x /usr/local/bin/yq
RUN curl -O -L  https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS}/prometheus-${PROMETHEUS}.linux-amd64.tar.gz && tar -xzvf prometheus-${PROMETHEUS}.linux-amd64.tar.gz && chmod +x prometheus-${PROMETHEUS}.linux-amd64/promtool && mv prometheus-${PROMETHEUS}.linux-amd64/promtool /usr/local/bin/promtool && promtool --version

