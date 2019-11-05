FROM busybox:1.31.0 as downloader
ARG CLAIR_SCANNER

RUN wget https://github.com/arminc/clair-scanner/releases/download/v${CLAIR_SCANNER}/clair-scanner_linux_amd64
RUN chmod +x clair-scanner_linux_amd64

FROM alpine:3.10.2

COPY --from=downloader clair-scanner_linux_amd64 /clair-scanner

ENTRYPOINT ["/clair-scanner"]


