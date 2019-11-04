#!/usr/bin/env bash
echo "waiting for docker to start"
let i=0; while ! docker ps; do let i=i+1; [ $i -le 12 ] || exit 1 && sleep 5; done || exit 1
set -e
kind create cluster --name "$NAME" --config /kind-config --image kindest/node:${K8S_VERSION} --wait 1m --loglevel=debug
export KUBECONFIG="$(kind get kubeconfig-path --name="$NAME")"
sed -i -E -e 's/localhost|0\.0\.0\.0/'"$CLUSTER_HOST"'/g' "$KUBECONFIG"
kubectl apply -f - <<EOF
---
# Source: hostpath-provisioner/templates/storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hostpath
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: hostpath

---
# Source: hostpath-provisioner/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: release-name-hostpath-provisioner
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
---
# Source: hostpath-provisioner/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: release-name-hostpath-provisioner
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
# Source: hostpath-provisioner/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: release-name-hostpath-provisioner
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: release-name-hostpath-provisioner
subjects:
  - kind: ServiceAccount
    name: release-name-hostpath-provisioner
    namespace: default
---
# Source: hostpath-provisioner/templates/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: release-name-hostpath-provisioner-leader-locking
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "update", "patch"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["list", "watch", "create"]
---
# Source: hostpath-provisioner/templates/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: release-name-hostpath-provisioner-leader-locking
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: release-name-hostpath-provisioner-leader-locking
subjects:
  - kind: ServiceAccount
    name: release-name-hostpath-provisioner
    namespace: default
---
# Source: hostpath-provisioner/templates/deployment.yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: release-name-hostpath-provisioner
  labels:
    app.kubernetes.io/name: hostpath-provisioner
    helm.sh/chart: hostpath-provisioner-0.2.3
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Tiller
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app.kubernetes.io/name: hostpath-provisioner
      app.kubernetes.io/instance: release-name
  template:
    metadata:
      labels:
        app.kubernetes.io/name: hostpath-provisioner
        app.kubernetes.io/instance: release-name
    spec:
      serviceAccountName: release-name-hostpath-provisioner
      containers:
        - name: hostpath-provisioner
          image: "quay.io/rimusz/hostpath-provisioner:v0.2.1"
          imagePullPolicy: IfNotPresent
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          volumeMounts:
            - name: pv-volume
              mountPath: /mnt/hostpath
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 128Mi
            
      volumes:
        - name: pv-volume
          hostPath:
            path: /mnt/hostpath
EOF
sleep 20
