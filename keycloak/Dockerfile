ARG KEYCLOAK
ARG KEYCLOAK_METRICS_SPI
FROM quay.io/keycloak/keycloak:${KEYCLOAK} as builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
# Install custom providers
RUN curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/${KEYCLOAK_METRICS_SPI}/keycloak-metrics-spi-${KEYCLOAK_METRICS_SPI}.jar -o /opt/keycloak/providers/keycloak-metrics-spi-${KEYCLOAK_METRICS_SPI}.jar
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KEYCLOAK}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]