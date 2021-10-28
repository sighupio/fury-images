#!/bin/bash

check_env_variable() {
    if [[ -z ${!1+set} ]]; then
       echo "Error: Define $1 environment variable"
       exit 1
    fi
}

check_file() {
if ! test -f "$1"; then
    echo "Error: $1 does not exist."
    exit 1
fi
}

# ------------------------------------------
# Check prerequisites
# ------------------------------------------

# vSphere
# check_env_variable VSPHERE_USER
# check_env_variable VSPHERE_PASSWORD
# check_env_variable VSPHERE_SERVER

# AWS (state locale) ?
# check_env_variable AWS_ACCESS_KEY_ID
# check_env_variable AWS_SECRET_ACCESS_KEY
# check_env_variable AWS_S3_BUCKET

# GIT Repository ?
# check_env_variable GIT_REPO_URL?

# Furyctl
# check_env_variable FURYCTL_TOKEN

# check_file /var/Furyfile.yaml
# check_file /var/cluster.yaml

# Cluster Metadata / Fury Metadata configmap 
# T.B.D.

# ------------------------------------------
# Launch furyctl
# ------------------------------------------

cp /var/cluster.yaml /furyctl/cluster.yml
furyctl cluster init --reset
furyctl cluster apply

# ------------------------------------------
# Install Fury
# ------------------------------------------

# KUBECONFIG
export KUBECONFIG=$PWD/furyctl/cluster/secrets/users/admin.conf

# Download Fury modules
furyctl vendor -H

# Apply Patches ??

# deploy-networking
kustomize build manifests/networking | kubectl apply -f - | grep -v unchanged

# deploy-vsphere
kustomize build manifests/vsphere | kubectl apply -f - | grep -v unchanged

# deploy-ingress
kustomize build manifests/ingress | kubectl apply -f - | grep -v unchanged

# deploy-logging
kustomize build manifests/logging | kubectl apply -f - | grep -v unchanged

# deploy-monitoring
kustomize build manifests/monitoring | kubectl apply -f - | grep -v unchanged

# deploy-ingress-infra
kustomize build manifests/ingress-infra | kubectl apply -f - | grep -v unchanged

# ------------------------------------------
# Push to repository again
# ------------------------------------------

# git init 
# git add remote robe
# git pusha tutto
