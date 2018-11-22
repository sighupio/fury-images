
FROM gitlab/gitlab-runner:v11.1.0

ARG KUBECTL_VERSION=1.11.1
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
    