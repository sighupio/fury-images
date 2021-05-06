FROM amazon/aws-cli:2.1.20

ARG KUBECTL=v1.18.12
ARG HELM=v3.2.3

RUN yum install -y ca-certificates gzip tar && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client && \
    curl -L https://get.helm.sh/helm-${HELM}-linux-amd64.tar.gz|tar xzv && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    helm version && \
    rm -r linux-amd64/ && \ 
    yum clean all && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/bin/bash"]
