FROM alpine:3.13

RUN apk add curl ca-certificates --no-cache --update
ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client
ENTRYPOINT [ "/usr/local/bin/kubectl" ]
