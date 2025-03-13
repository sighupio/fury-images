#!/usr/bin/env sh

CONFIG_FILE="/k8s/config.yaml"
ETCDCTL_ENDPOINTS="https://127.0.0.1:2379"

if [ -f "$CONFIG_FILE" ]; then
    ENDPOINTS=$(yq eval '.etcd.external.endpoints | join(",")' "$CONFIG_FILE")
    
    [ -n "$ENDPOINTS" ] && ETCDCTL_ENDPOINTS="$ENDPOINTS"
fi

ETCDCTL_API=3 \
ETCDCTL_ENDPOINTS="$ETCDCTL_ENDPOINTS" \
ETCDCTL_CACERT="$ETCDCTL_CACERT" \
ETCDCTL_CERT="$ETCDCTL_CERT" \
ETCDCTL_KEY="$ETCDCTL_KEY" \
etcdctl snapshot save /backup/fury-etcd-snapshot-$(date +'%Y%m%d%H%M').etcdb
