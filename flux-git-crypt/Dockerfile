ARG FLUX
FROM fluxcd/flux:${FLUX}

ENV PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/lib/kubeyaml

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community git-crypt && \
    apk add --no-cache curl

ARG KUSTOMIZE
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    kustomize version
