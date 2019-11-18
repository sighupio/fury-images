ARG PYTHON
FROM python:${PYTHON}
ARG KUSTOMIZE
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE}/kustomize_kustomize.v${KUSTOMIZE}_linux_amd64 -o /usr/local/bin/kustomize && chmod +x /usr/local/bin/kustomize && kustomize version
COPY test-requirements.txt .
RUN pip install -r test-requirements.txt
