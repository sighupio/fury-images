ARG GIT_VERSION

FROM bitnami/git:${GIT_VERSION}

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git-crypt
