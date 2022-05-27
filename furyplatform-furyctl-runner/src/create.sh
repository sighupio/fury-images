#!/bin/bash

set -a
set -e
set -o pipefail
set -u

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
# SEND NOTIFICATION TO SLACK/MAIL/OTHERS
# https://api.slack.com/tutorials/tracks/posting-messages-with-curl
# -----------------------------------------------------------------
notify() {
  echo "📬  sending Slack notification... "

  curl -H "Content-type: application/json" \
    --data "$1" \
    -H "Authorization: Bearer ${SLACK_TOKEN}" \
    --output /dev/null -s \
    -X POST https://slack.com/api/chat.postMessage
}

notify_error() {
  if [ $? -ne 0 ]; then
    notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* creation has failed :flushed:\"}}]}"
  fi
}

notify_start() {
  notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Starting creation of cluster *${CLUSTER_FULL_NAME}* :hammer_and_wrench:\"}}]}"
}

notify_finish() {
  notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* has been created :tada:\"}}]}"
}

trap notify_error EXIT

# ------------------------------------------
# Check prerequisites
# ------------------------------------------

echo -n "🛫  performing pre-flight checks... "

case $PROVIDER_NAME in
"vsphere")
  # vSphere
  check_env_variable VSPHERE_USER
  check_env_variable VSPHERE_PASSWORD
  check_env_variable VSPHERE_SERVER
  ;;
"aws")
  # AWS
  check_env_variable AWS_ACCESS_KEY_ID
  check_env_variable AWS_SECRET_ACCESS_KEY
  check_env_variable AWS_S3_BUCKET
  ;;
"gcp")
  # GCP
  check_env_variable GOOGLE_CREDENTIALS
  ;;
*)
  # ERROR
  echo "Provider $PROVIDER_NAME not supported"
  JOB_RESULT=1
  notify
  exit 1
  ;;
esac

# KFD Karrier Module
check_env_variable KARRIER_MODULE_VERSION

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

notify_start

# Create .netrc file to make authenticated git requests
echo "machine github.com login ${CLUSTER_ENVIRONMENT} password ${FURYCTL_TOKEN}" > ~/.netrc

# -------------------------------------------------------------------------
# Clone the repo where we'll put all the stuff and cd into it
# -------------------------------------------------------------------------

git clone ${GIT_REPO_URL} ${BASE_WORKDIR}

# If we find a git crypt key, let's unlock the repo.
if [[ -f "/var/git-crypt.key" ]]; then
  echo "🔐  unlocking the git repo"
  cat /var/git-crypt.key | base64 -d >/tmp/git-crypt.key
  git-crypt unlock /tmp/git-crypt.key
fi

mkdir -p ${WORKDIR}
echo "switching to workdir: ${WORKDIR}"
cd ${WORKDIR}

# ------------------------------------------
# Launch furyctl
# ------------------------------------------
echo "🚀  starting cluster creation"
cp /var/cluster.yml ${WORKDIR}/cluster.yml

furyctl cluster init --reset

# Create terraform and ansible log files, and stream their output

mkdir -p ${WORKDIR}/cluster/logs

touch ${WORKDIR}/cluster/logs/terraform.logs
touch ${WORKDIR}/cluster/logs/ansible.log

tail -f ${WORKDIR}/cluster/logs/terraform.logs &
tail -f ${WORKDIR}/cluster/logs/ansible.log &

# sometimes in vSphere the apply failing with apparently no reason, and re-launching it, it ends successfully
FURYCTL_RETRY=1
FURYCTL_MAX_RETRIES=3
while furyctl cluster apply; JOB_RESULT=$?; [ ${FURYCTL_RETRY} -lt ${FURYCTL_MAX_RETRIES} ] && [ ${JOB_RESULT} -ne 0 ]; do
  sleep $(( ${FURYCTL_RETRY} * 10 ))
  FURYCTL_RETRY=$(( ${FURYCTL_RETRY} + 1 ))
done

if [ ${JOB_RESULT} -ne 0 ]; then
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

# Copy presets ("manifests templates") to cluster folder
cp -r ${BASE_WORKDIR}/presets ${WORKDIR}/manifests

# Update the ingress hostname accordingly
grep -rl '{{INGRESS_BASE_URL}}' manifests | xargs sed -i s/{{INGRESS_BASE_URL}}/${INGRESS_BASE_URL}/

# Update the cluster cidr in the networking patch using the info from cluster.yml
# We use ~ as separator instead of / to avoid the confusion with the slash in the network cidr
CLUSTER_POD_CIDR=$(yq eval .spec.clusterPODCIDR /var/cluster.yml)
sed -i s~{{CALICO_IPV4POOL_CIDR}}~${CLUSTER_POD_CIDR}~ manifests/modules/networking/patches/calico-ds.yml

# deploy common modules
kustomize build manifests/modules | kubectl apply -f -

# deploy provider-specific modules
if [ -d "manifests/providers/${PROVIDER_NAME}" ]; then
  kustomize build "manifests/providers/${PROVIDER_NAME}" | kubectl apply -f -
fi

# Waiting for master node to be ready
echo "⏱  waiting for master node to be ready... "
kubectl wait --for=condition=Ready nodes/${CLUSTER_FULL_NAME}-master-1.localdomain --timeout 5m

# TODO: FIXME this is a workaround because we have a random issue on vSphere that sometimes doesn't finds the nodes
for node in $(kubectl get nodes -ojsonpath='{.items[*].metadata.name}'); do
  # echo "forcing untaint of node $node"
  kubectl taint node $node node.cloudprovider.kubernetes.io/uninitialized-
done

# ------------------------------------------
# Deploy Cluster Metadata and Fury Metadata
# ------------------------------------------

# TODO: when we will have the module with tags, we will substitute this deploy enriching the existing Furyfile
#  with the module version
target="https://github.com/sighupio/fury-kubernetes-karrier/katalog/karrier/agent?ref=${KARRIER_MODULE_VERSION}"

kustomize build ${target} | kubectl apply -f -

# ------------------------------------------
# Push to repository our changes
# ------------------------------------------

# Mitigate the git commit error since GIT_COMMITTER_NAME and GIT_COMMITTER_EMAIL are not used during the commit command
GIT_AUTHOR_NAME=${GIT_COMMITTER_NAME}
GIT_AUTHOR_EMAIL=${GIT_COMMITTER_EMAIL}

git pull --rebase --autostash
git add ${BASE_WORKDIR}
git commit -m "Create cluster ${CLUSTER_FULL_NAME}"
git push

# FINISH

echo
echo "we're done! enjoy your cluster 🎉"
echo

notify_finish
