FROM alpine
RUN apk add curl wget bash

ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

ARG KUSTOMIZE
#https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.10.0/kustomize_v3.10.0_linux_amd64.tar.gz
RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE}/kustomize_v${KUSTOMIZE}_linux_amd64.tar.gz -O kustomize.tar.gz
RUN tar -zxvf kustomize.tar.gz
RUN cp kustomize /usr/local/bin/kustomize
RUN chmod +x /usr/local/bin/kustomize
RUN kustomize version


COPY plugin.sh /drone/plugin.sh
ENTRYPOINT [ "/drone/plugin.sh" ]