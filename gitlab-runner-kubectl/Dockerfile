ARG GITLABRUNNER
FROM gitlab/gitlab-runner:${GITLABRUNNER}
ARG KUBECTL=1.11.1
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
    
