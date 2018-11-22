#!/usr/bin/dumb-init /bin/sh

set -e
set -x

mkdir -p /fluentd/etc
cp /etc/tmp-conf/* /fluentd/etc/

if [ -z ${FLUENT_ELASTICSEARCH_USER} ] ; then
   sed -i  '/FLUENT_ELASTICSEARCH_USER/d' /fluentd/etc/${FLUENTD_CONF}
fi

if [ -z ${FLUENT_ELASTICSEARCH_PASSWORD} ] ; then
   sed -i  '/FLUENT_ELASTICSEARCH_PASSWORD/d' /fluentd/etc/${FLUENTD_CONF}
fi

exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins --gemfile /fluentd/Gemfile ${FLUENTD_OPT}
