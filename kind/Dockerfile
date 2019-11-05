FROM docker:dind

ARG KUBERNETES
ARG KUSTOMIZE
ARG KIND
RUN apk add --no-cache git make musl-dev go jq curl bash nodejs nodejs-npm openssl \
  && curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/${KIND}/kind-linux-amd64 && chmod +x kind && mv kind /usr/local/bin/ \
  && npm install -g bats \
  && curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES}/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/ \
  && curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_kustomize.v${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize \
  && chmod +x /usr/local/bin/kustomize && kustomize version

WORKDIR /tests
ENV PATH="${PATH}:/root/go/bin"
COPY kind-config-${KIND} /kind-config
COPY setup.sh .
ENTRYPOINT ["bash", "-c"]
ENV NAME test
ENV K8S_VERSION ${KUBERNETES}
CMD ["bash /tests/setup.sh && export KUBECONFIG=/kubeconfig && bats -p $TESTS"]

