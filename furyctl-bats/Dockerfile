ARG FURYCTL
FROM quay.io/sighup/furyctl:${FURYCTL}
RUN apk add --no-cache bash nodejs npm curl && npm install -g bats

ARG KUSTOMIZE

RUN curl -LOs https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_kustomize.v${KUSTOMIZE}_linux_amd64 && \
    chmod +x kustomize_kustomize.v${KUSTOMIZE}_linux_amd64 && \
    mv kustomize_kustomize.v${KUSTOMIZE}_linux_amd64 /usr/local/bin/kustomize &&  kustomize version
