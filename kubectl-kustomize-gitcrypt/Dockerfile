FROM alpine:3.9

ARG GIT_CRYPT
RUN apk add bash curl ca-certificates git g++ make openssl openssl-dev --no-cache --update && \
    curl -L https://github.com/AGWA/git-crypt/archive/$GIT_CRYPT.tar.gz | tar zxv -C /var/tmp  && \ 
    cd /var/tmp/git-crypt-$GIT_CRYPT && make && make install && \
    rm -r /var/tmp/git-crypt-$GIT_CRYPT 

ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

ARG KUSTOMIZE
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    kustomize version
