FROM docker:dind

RUN apk add --no-cache git make musl-dev go curl \
  && go get sigs.k8s.io/kind
RUN curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v1.0.11/kustomize_1.0.11_linux_amd64 -o /usr/local/bin/kustomize \
  && chmod +x /usr/local/bin/kustomize && kustomize version
RUN apk add --update nodejs nodejs-npm && npm install -g bats
RUN apk add bash

WORKDIR /tests
ENV PATH="${PATH}:/root/go/bin"
COPY kind-config /kind-config
COPY test_deploy.bats ./common.bats
COPY tests.bats ./
ENTRYPOINT ["bash", "-c"]
CMD ["sleep 10 && bats /tests/common.bats"]
