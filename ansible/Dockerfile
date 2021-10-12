FROM alpine:3.14

ARG ANSIBLE_VERSION
ARG ANSIBLE_LINT_VERSION

RUN apk --update --no-cache add \
    bash \
    curl \
    gcc \
    git \
    libc-dev \
    python3-dev \
    libffi-dev \
    python3 \
    py3-pip

RUN pip3 install --upgrade \
    pip \
    cffi

RUN pip3 install ansible==${ANSIBLE_VERSION} \
                 ansible-lint==${ANSIBLE_LINT_VERSION}
