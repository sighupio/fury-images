ARG FURYCTL
ARG KUSTOMIZE
FROM sighup/furyctl:${FURYCTL}
RUN apk add --no-cache bash nodejs npm curl && npm install -g bats \
  && curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize \
  && chmod +x /usr/local/bin/kustomize && kustomize version
