ARG OPA
ARG BUSYBOX
ARG ALPINE

FROM openpolicyagent/opa:${OPA} as opa

FROM busybox:${BUSYBOX} as conftest
ARG CONFTEST
RUN wget https://github.com/instrumenta/conftest/releases/download/v${CONFTEST}/conftest_${CONFTEST}_Linux_x86_64.tar.gz
RUN tar xvzf conftest_${CONFTEST}_Linux_x86_64.tar.gz

FROM alpine:${ALPINE}

USER opa:opa
COPY --chown=opa:opa --from=opa /opa /bin/
COPY --chown=opa:opa --from=conftest conftest /bin/
