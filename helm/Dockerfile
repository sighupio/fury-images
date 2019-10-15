ARG ALPINE

FROM alpine:${ALPINE} as downloader
ARG HELM

RUN wget https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz
RUN tar xvzf helm-v${HELM}-linux-amd64.tar.gz

FROM alpine:${ALPINE}
COPY --from=downloader linux-amd64/helm /bin/helm 
