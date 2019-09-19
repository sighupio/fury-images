ARG OPA
FROM openpolicyagent/opa:${OPA} as opa

ARG ALPINE
FROM alpine:${ALPINE}

COPY --from=opa /opa /opa

ARG USER

USER ${USER}

ENTRYPOINT ["/opa"]
CMD ["run"]
