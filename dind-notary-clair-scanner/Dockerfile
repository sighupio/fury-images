ARG DIND
ARG BUSYBOX

FROM busybox:${BUSYBOX} AS downloader
ARG NOTARY
ARG CLAIR_SCANNER

RUN wget https://github.com/theupdateframework/notary/releases/download/v${NOTARY}/notary-Linux-amd64
RUN chmod +x notary-Linux-amd64

RUN wget https://github.com/arminc/clair-scanner/releases/download/v${CLAIR_SCANNER}/clair-scanner_linux_amd64
RUN chmod +x clair-scanner_linux_amd64


FROM docker:${DIND}-dind

COPY --from=downloader notary-Linux-amd64 /bin/notary

COPY --from=downloader clair-scanner_linux_amd64 /clair-scanner
