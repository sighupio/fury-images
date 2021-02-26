FROM maven:3-jdk-13-alpine

WORKDIR /usr/src/app

FROM openjdk:8-jre-alpine

ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV SHA512_VAL=a1b931a25c513f83f4f712cc126ee67a2b196ea23a243aa6cafe357ea03f721fba6cb566701e5c0e1f2f7ad8954807361364635c45d5069ec2dbf0ba5c6b588b

ENV AGENT_SHA512=17d275cca87eb5d593cc31ffa704587c0e867c8ae6e1eab0a5a54598bbb84b79ba3f7fad26ef6b3f2fa2f05ffee61c2d733dfb9536d2b067ecd37f485330b5e8
ENV AGENT_BASE=jmx_prometheus_javaagent
ENV AGENT=$AGENT_BASE-$AGENT_VERSION.jar
ENV AGENT_CONFIG=jmx_exporter.yml
ENV AGENT_PORT=8080
ENV AGENT_OPTS="-javaagent:/$AGENT=$AGENT_PORT:/jmx_exporter.yml"
ENV ACTIVEMQ_OPTS_MEMORY="-Xms64M -Xmx1G"
ENV ACTIVEMQ_HOME /opt/activemq
ENV ACTIVEMQ_CONF=$ACTIVEMQ_HOME/conf

RUN set -x && \
    mkdir -p /opt && \
    apk --update add --virtual build-dependencies curl && \
    curl https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz -o $ACTIVEMQ-bin.tar.gz

# Validate checksum
RUN if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ];\
    then \
        echo "sha512 values doesn't match! exiting."  && \
        exit 1; \
    fi;

RUN tar xzf $ACTIVEMQ-bin.tar.gz -C  /opt && \
    ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    addgroup -S activemq && adduser -S -H -G activemq -h $ACTIVEMQ_HOME activemq && \
    chown -R activemq:activemq /opt/$ACTIVEMQ && \
    chown -h activemq:activemq $ACTIVEMQ_HOME && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

# Download jmx-exporter javaagent
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/$AGENT_BASE/$AGENT_VERSION/$AGENT /

# Validate checksum
RUN chmod 0644 /$AGENT && if [ "$AGENT_SHA512" != "$(cd / && sha512sum $AGENT | awk '{print($1)}')" ]; then \
        echo "Agent sha512 value doesn't match! exiting."  && exit 1; \
    fi

COPY $AGENT_CONFIG /

ENV ACTIVEMQ_OPTS="$AGENT_OPTS $ACTIVEMQ_OPTS_MEMORY -Djava.util.logging.config.file=logging.properties -Djava.security.auth.login.config=$ACTIVEMQ_CONF/login.config"

USER activemq

WORKDIR $ACTIVEMQ_HOME
EXPOSE $ACTIVEMQ_TCP $ACTIVEMQ_AMQP $ACTIVEMQ_STOMP $ACTIVEMQ_MQTT $ACTIVEMQ_WS $ACTIVEMQ_UI

CMD ["/bin/sh", "-c", "bin/activemq console"]
