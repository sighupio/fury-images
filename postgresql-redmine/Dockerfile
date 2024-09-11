ARG POSTGRESQL

FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRESQL}

USER root

ARG POSTGRESQL

RUN set -xe; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		"postgresql-${POSTGRESQL}-pg-stat-kcache" ; \
	rm -fr /tmp/* ; \
	rm -rf /var/lib/apt/lists/*;

USER 26
