ARG OPA
ARG CONFTEST
ARG ALPINE
ARG BUSYBOX

FROM openpolicyagent/opa:${OPA} as opa

FROM busybox:${BUSYBOX} as conftest
RUN wget https://github.com/instrumenta/conftest/releases/download/v${CONFTEST}/conftest_${CONFTEST}_Linux_x86_64.tar.gz
RUN tar xvzf conftest_${CONFTEST}_Linux_x86_64.tar.gz

FROM alpine:${ALPINE}

COPY --from=opa /opa /opa
COPY --from=conftest conftest /bin/
ENTRYPOINT ["/opa"]
CMD ["run"]
