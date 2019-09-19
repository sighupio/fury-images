ARG OPA
ARG ALPINE
FROM openpolicyagent/opa:${OPA} as opa

FROM alpine:${ALPINE}

COPY --from=opa /opa /opa

ENTRYPOINT ["/opa"]
CMD ["run"]
