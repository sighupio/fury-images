# etcd-backupper
A simple Alpine-based image which contains `etcdctl` and `yq` to
assist the `etcd-backup-*` features.

## Endpoint detection
There is some logic to try to automatically detect which endpoints
are the `etcd` server listening on, but in order to make this work
you have to mount the `ClusterConfiguration` config-map as a volume
under `/k8s/config.yaml`. If this isn't mounted, there's a fallback
endpoint (`https://127.0.0.1:2379`).
