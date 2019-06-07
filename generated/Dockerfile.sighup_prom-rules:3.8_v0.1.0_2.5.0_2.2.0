FROM alpine:3.8
RUN apk add --no-cache --update ca-certificates curl bash
RUN curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/2.2.0/yq_linux_amd64 && chmod +x /usr/local/bin/yq
RUN curl -O -L  https://github.com/prometheus/prometheus/releases/download/v2.5.0/prometheus-2.5.0.linux-amd64.tar.gz && tar -xzvf prometheus-2.5.0.linux-amd64.tar.gz && chmod +x prometheus-2.5.0.linux-amd64/promtool && mv prometheus-2.5.0.linux-amd64/promtool /usr/local/bin/promtool && promtool --version

