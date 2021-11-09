#!/bin/bash

set -u
set -o nounset
# set -e

check_env_variable() {
    if [[ -z ${!1+set} ]]; then
       echo "Error: Define $1 environment variable"
       JOB_RESULT=1
       notify
       exit 1
    fi
}

check_file() {
if ! test -f "$1"; then
    echo "Error: $1 does not exist."
    JOB_RESULT=1
    notify
    exit 1
fi
}

# -----------------------------------------------------------------
# SEND NOTIFICATION OF THE JOB RESULT TO SLACK/MAIL/OTHERS
# https://api.slack.com/tutorials/tracks/posting-messages-with-curl
# -----------------------------------------------------------------
notify() {
    # JOB_RESULT is the exit codes of all commands, if one of them != 0, then we failed
    if [[ "${JOB_RESULT}" = 0 ]] ; then
        message="{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* has been created :tada:\"}}]}"
    else
        message="{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* creation has failed :flushed:\"}}]}"
    fi

    echo "📬  sending Slack notification... "

    curl -H "Content-type: application/json" \
    --data  "${message}" \
    -H "Authorization: Bearer ${SLACK_TOKEN}" \
    --output /dev/null -s \
    -X POST https://slack.com/api/chat.postMessage

    exit ${JOB_RESULT}
}

# ------------------------------------------
# Check prerequisites
# ------------------------------------------

echo -n "🛫  performing pre-flight checks... "

# vSphere
check_env_variable VSPHERE_USER
check_env_variable VSPHERE_PASSWORD
check_env_variable VSPHERE_SERVER

# AWS 
# check_env_variable AWS_ACCESS_KEY_ID
# check_env_variable AWS_SECRET_ACCESS_KEY
# check_env_variable AWS_S3_BUCKET

# GIT Repository 
check_env_variable GIT_REPO_URL
check_env_variable GIT_COMMITTER_NAME
check_env_variable GIT_COMMITTER_EMAIL

# Furyctl
check_env_variable FURYCTL_TOKEN
check_env_variable CLUSTER_NAME
check_env_variable CLUSTER_ENVIRONMENT

# Slack
check_env_variable SLACK_TOKEN
check_env_variable SLACK_CHANNEL

# INGRESS_BASE_URL for creating the patches
check_env_variable INGRESS_BASE_URL

check_file /var/Furyfile.yml
check_file /var/cluster.yml

# Cluster Metadata / Fury Metadata configmap
# T.B.D.

echo "OK."

# Auxiliary ENV VARS
JOB_RESULT=0
BASE_WORKDIR="/workdir"
CLUSTER_FULL_NAME=${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}
WORKDIR="${BASE_WORKDIR}/${CLUSTER_FULL_NAME}"


# Let's start!

echo "📬  sending Slack notification... "
curl -H "Content-type: application/json" \
--data "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Starting creation of cluster *${CLUSTER_FULL_NAME}* :hammer_and_wrench:\"}}]}" \
-H "Authorization: Bearer ${SLACK_TOKEN}" \
--output /dev/null -s \
-X POST https://slack.com/api/chat.postMessage

# -------------------------------------------------------------------------
# Clone the repo where we'll put all the stuff and cd into it
# -------------------------------------------------------------------------

git clone ${GIT_REPO_URL} ${BASE_WORKDIR}
if [ $? -ne 0 ]; then
    JOB_RESULT=1
    # If the git clone fails we can't move on. Let's notify & exit.
    notify
fi

# If we find a git crypt key, let's unlock the repo.
if [[ -f "/var/git-crypt.key" ]]; then
    echo "🔐  unlocking the git repo"
    git-crypt unlock /var/git-crypt.key
    if [ $? -ne 0 ]; then
        JOB_RESULT=1
    fi

fi

mkdir -p $WORKDIR
echo "switching to workdir: ${WORKDIR}"
cd $WORKDIR

# ------------------------------------------
# Launch furyctl
# ------------------------------------------
echo "🚀  starting cluster creation"
cp /var/cluster.yml ${WORKDIR}/cluster.yml

furyctl cluster init --reset
if [ $? -ne 0 ]; then
    JOB_RESULT=1
    notify
fi

furyctl cluster apply
if [ $? -ne 0 ]; then
    JOB_RESULT=1
    notify
fi

# ------------------------------------------
# Install Fury
# ------------------------------------------

echo "🐉  deploying Kubernetes Fury Distribution"

# KUBECONFIG
export KUBECONFIG=${WORKDIR}/cluster/secrets/users/admin.conf

cp /var/Furyfile.yml ${WORKDIR}/Furyfile.yml
# Download Fury modules
furyctl vendor -H
if [ $? -ne 0 ]; then
    JOB_RESULT=1
    notify
fi

# Copy presets ("manifests templates") to cluster folder
cp -r ${BASE_WORKDIR}/presets ${WORKDIR}/manifests

# Update the ingress hostname accordingly
grep -rl '{{INGRESS_BASE_URL}}' manifests | xargs sed -i s/{{INGRESS_BASE_URL}}/${INGRESS_BASE_URL}/

# Update the cluster cidr in the networking patch using the info from cluster.yml
# We use ~ as separator instead of / to avoid the confusion with the slash in the network cidr
CLUSTER_POD_CIDR=$(yq eval .spec.clusterPODCIDR /var/cluster.yml)
sed -i s~{{CALICO_IPV4POOL_CIDR}}~${CLUSTER_POD_CIDR}~ manifests/modules/networking/patches/calico-ds.yml

# deploy modules
kustomize build manifests/modules | kubectl apply -f -

# Waiting for master node to be ready
echo "⏱  waiting for master node to be ready... "
kubectl wait --for=condition=Ready nodes/${CLUSTER_FULL_NAME}-master-1.localdomain --timeout 5m

# TODO: FIXME this is a workaround because we have a random issue on vSphere that sometimes doesn't finds the nodes
for node in $(kubectl get nodes -ojsonpath='{.items[*].metadata.name}');do
    # echo "forcing untaint of node $node"
    kubectl taint node $node node.cloudprovider.kubernetes.io/uninitialized-
done


# ------------------------------------------
# Deploy Cluster Metadata and Fury Metadata
# ------------------------------------------
kustomize build manifests/fip | kubectl apply -f -

# ------------------------------------------
# Push to repository our changes
# ------------------------------------------

git pull --rebase --autostash
git add ${BASE_WORKDIR}
git commit -m "Create cluster ${CLUSTER_FULL_NAME}"
git push
if [ $? -ne 0 ]; then
    JOB_RESULT=1
fi

# FINISH

echo
echo "we're done! enjoy your cluster 🎉"
echo

notify
