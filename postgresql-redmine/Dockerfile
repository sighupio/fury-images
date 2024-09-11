ARG POSTGRESQL

FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRESQL}

USER root

RUN apt update && apt install -y postgresql-15-pg-stat-kcache

ARG POSTGRESQL

RUN set -xe; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		"postgresql-${POSTGRESQL}-pg-stat-kcache" ; \
	rm -fr /tmp/* ; \
	rm -rf /var/lib/apt/lists/*;

USER 26
