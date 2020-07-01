ARG FLUX
FROM fluxcd/flux:${FLUX}

ENV PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/lib/kubeyaml
RUN apk add --no-cache curl
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community git-crypt

ARG KUSTOMIZE=3.5.4
RUN curl -LOs https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    tar -zxvf kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize