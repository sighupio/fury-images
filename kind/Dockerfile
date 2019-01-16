FROM docker:dind

ARG KUBECTL
ARG KUSTOMIZE
RUN apk add --no-cache git make musl-dev go jq curl bash nodejs nodejs-npm openssl \
  && go get sigs.k8s.io/kind && npm install -g bats \
  && curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/ \
  && curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE}/kustomize_${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize \
  && chmod +x /usr/local/bin/kustomize && kustomize version \
  && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

WORKDIR /tests
ENV PATH="${PATH}:/root/go/bin"
COPY kind-config /kind-config
COPY setup.sh .
ENTRYPOINT ["bash", "-c"]
ENV NAME test
CMD ["bash /tests/setup.sh && export KUBECONFIG=\"$(kind get kubeconfig-path --name=\"$NAME\")\" && bats -p $TESTS"]

