FROM ubuntu:latest as builder

RUN apt-get update && apt-get install curl wget git -y

ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

ENV HOME=/root
RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"
RUN asdf plugin-add kustomize https://github.com/Banno/asdf-kustomize.git

ARG KUBEVAL
RUN wget https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL}/kubeval-linux-amd64.tar.gz -O kubeval.tar.gz
RUN tar -zxvf kubeval.tar.gz
RUN cp kubeval /usr/local/bin

ARG KUSTOMIZE

RUN asdf install kustomize ${KUSTOMIZE}
RUN asdf global kustomize ${KUSTOMIZE}
RUN cp /root/.asdf/installs/kustomize/${KUSTOMIZE}/bin/kustomize /usr/local/bin
RUN /usr/local/bin/kustomize version


FROM alpine:3.9
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl
RUN kubectl version --client
COPY --from=builder /usr/local/bin/kustomize /usr/local/bin/kustomize
RUN kustomize version
COPY --from=builder /usr/local/bin/kubeval /usr/local/bin/kubeval
RUN kubeval --version
