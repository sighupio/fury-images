ARG OPA
ARG ALPINE
ARG BUSYBOX
FROM openpolicyagent/opa:${OPA} as opa

FROM busybox:${BUSYBOX} as conftest
RUN wget https://github.com/instrumenta/conftest/releases/download/v0.11.0/conftest_0.11.0_Linux_x86_64.tar.gz
RUN tar xvzf conftest_0.11.0_Linux_x86_64.tar.gz 

FROM alpine:${ALPINE}

COPY --from=opa /opa /opa
COPY --from=conftest conftest /bin/
ENTRYPOINT ["/opa"]
CMD ["run"]
