ARG OPA
FROM openpolicyagent/opa:${OPA} AS opa

ARG ALPINE
FROM alpine:${ALPINE}

COPY --from=opa /opa /opa

ARG USER 0

USER ${USER}

ENTRYPOINT ["/opa"]
CMD ["run"]
