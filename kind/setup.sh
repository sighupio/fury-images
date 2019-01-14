#!/usr/bin/env bash
kind create cluster --name "$NAME" --config /kind-config --wait 1m
export KUBECONFIG="$(kind get kubeconfig-path --name="$NAME")"
sed -i 's/localhost/'"$CLUSTER_HOST"'/g' "$KUBECONFIG"
kubectl delete storageclass standard
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
helm init --service-account tiller
helm repo add rimusz https://charts.rimusz.net
helm repo update
sleep 20
helm upgrade --install hostpath-provisioner --namespace kube-system rimusz/hostpath-provisioner
