#!/bin/bash
set -u
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

echo -n "🛫  performing pre-flight checks... "

# vSphere
check_env_variable VSPHERE_USER
check_env_variable VSPHERE_PASSWORD
check_env_variable VSPHERE_SERVER

# AWS (state locale) ? YES
# check_env_variable AWS_ACCESS_KEY_ID
# check_env_variable AWS_SECRET_ACCESS_KEY
# check_env_variable AWS_S3_BUCKET

# GIT Repository ?
check_env_variable GIT_REPO_URL
check_env_variable GIT_COMMITTER_NAME
check_env_variable GIT_COMMITTER_EMAIL

# Furyctl
check_env_variable FURYCTL_TOKEN

# SLACK NOTIFICATION TOKEN (?)
# check_env_variable SLACK_TOKEN

# INGRESS_BASE_URL for creating the patches
# check_env_variable INGRESS_BASE_URL

check_file /var/Furyfile.yml
check_file /var/cluster.yml

# Cluster Metadata / Fury Metadata configmap
# T.B.D.

echo "OK."

BASE_WORKDIR="/workdir"

# -------------------------------------------------------------------------
# Clone the repo where we'll put all the stuff and cd into it
# -------------------------------------------------------------------------

git clone ${GIT_REPO_URL} ${BASE_WORKDIR}

# If we find a git crypt key, let's unlock the repo.
if [[ -f "/var/git-crypt.key" ]]; then
    echo "🔐  unlocking the git repo"
    git-crypt unlock /var/git-crypt.key
fi

# We should have these 2 env vars mounted as env vars from the Fleet API
CLUSTER_NAME=$(yq eval .metadata.name /var/cluster.yml)
CLUSTER_ENVIRONMENT=$(yq eval .spec.environmentName /var/cluster.yml)

WORKDIR="${BASE_WORKDIR}/${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}"
mkdir -p $WORKDIR

echo "switching to workdir: ${WORKDIR}"
cd $WORKDIR

# ------------------------------------------
# Launch furyctl
# ------------------------------------------
echo "🚀  starting cluster creation"
cp /var/cluster.yml ${WORKDIR}/cluster.yml
furyctl cluster init --reset
furyctl cluster apply

# ------------------------------------------
# Install Fury
# ------------------------------------------

echo "🐉  deploying Kubernetes Fury Distribution"

# KUBECONFIG
export KUBECONFIG=${WORKDIR}/cluster/secrets/users/admin.conf

cp /var/Furyfile.yml ${WORKDIR}/Furyfile.yml
# Download Fury modules
furyctl vendor -H

# Apply Patches ??
cp -r ${BASE_WORKDIR}/presets/manifests ${WORKDIR}/manifests

# UPDATE THE INGRESS HOSTNAME ACCORDINGLY
sed -i s/{{INGRESS_HOSTNAME}}/${INGRESS_BASE_URL}/ manifests/ingress-infra/resources/*

# UPDATE THE CLUSTER CIDR IN THE NETWORKING PATCH USING THE INFO FROM cluster.yaml

# deploy modules
kustomize build manifests | kubectl apply -f -

# Waiting for master node to be ready
echo "⏱  waiting for master node to be ready... "
kubectl wait --for=condition=Ready nodes/furyplatform-demo-master-1.localdomain --timeout 5m

# ------------------------------------------
# Push to repository again
# ------------------------------------------

git add ${BASE_WORKDIR}
git commit -m "changes made by furyctl runner"
git push

# -----------------------------------------------------------------
# SEND NOTIFICATION OF THE JOB RESULT TO SLACK/MAIL/OTHERS
# https://api.slack.com/tutorials/tracks/posting-messages-with-curl
# -----------------------------------------------------------------

# curl -H "Content-type: application/json" \
# --data '{"channel":"C123456","blocks":[{"type":"section","text":{"type":"mrkdwn","text":"You cluster ${CLUSERNAME} has been created :tada:."}}]}' \
# -H "Authorization: Bearer ${SLACK_TOKEN}" \
# -X POST https://slack.com/api/chat.postMessage
echo
echo "we're done! enjoy your cluster 🎉"
echo