FROM ubuntu:latest as builder

RUN apt-get update && apt-get install curl wget -y

ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

RUN wget https://github.com/nutellinoit/kubenvz/releases/download/v0.3.0/kubenvz_linux_x64_v0.3.0.tar.gz -O kubenvz.tar.gz
RUN tar -zxvf kubenvz.tar.gz
RUN ls -la

ARG KUSTOMIZE

RUN /kubenvz kustomize install $(/kubenvz kustomize list remote | grep ${KUSTOMIZE})
RUN /kubenvz kustomize use ${KUSTOMIZE}
RUN cp $(readlink $(which kustomize)) /kustomize

RUN /kustomize version

FROM alpine
RUN apk add --no-cache curl make git bash
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl
RUN kubectl version --client
COPY --from=builder /kustomize /usr/local/bin/kustomize
RUN kustomize version
RUN kubectl version --client
COPY plugin.sh /drone/plugin.sh
ENTRYPOINT [ "/drone/plugin.sh" ]