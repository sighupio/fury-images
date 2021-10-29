ARG GITLABRUNNER
FROM gitlab/gitlab-runner:${GITLABRUNNER}
ARG KUBECTL
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client
ARG HELM
RUN curl -L https://get.helm.sh/helm-${HELM}-linux-amd64.tar.gz | tar xzv && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    helm version
