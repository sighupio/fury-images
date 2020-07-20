FROM alpine
RUN apk add --no-cache curl make git bash openssh-client

ARG KUSTOMIZE
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    kustomize version

COPY plugin.sh /drone/plugin.sh
ENTRYPOINT [ "/drone/plugin.sh" ]
