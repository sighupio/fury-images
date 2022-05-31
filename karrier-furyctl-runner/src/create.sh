#!/bin/bash

set -a
set -e
set -o pipefail
set -u

SHOULD_COMMIT_AND_PUSH=0

# $1: command to be eval'd
# $2: seconds to sleep
# $3: max retries
retry_command() {
  COMMAND="$1"
  SLEEP_SECONDS="$2"
  MAX_RETRIES="$3"
  RETRY=1
  while eval "${COMMAND}"; JOB_RESULT=$?; [ ${RETRY} -lt ${MAX_RETRIES} ] && [ ${JOB_RESULT} -ne 0 ]; do
    BACKOFF_SECONDS=$(( ${RETRY} * ${SLEEP_SECONDS} ))
    echo "failed running '${COMMAND}', retrying in ${BACKOFF_SECONDS} seconds..."
    sleep "${BACKOFF_SECONDS}"
    RETRY=$(( ${RETRY} + 1 ))
  done

  if [[ ${JOB_RESULT} -ne 0 ]]; then
    exit 1
  fi
}

check_env_variable() {
  if [[ -z ${!1+set} ]]; then
    echo "Error: Define $1 environment variable"
    JOB_RESULT=1
    exit 1
  fi
}

check_file() {
  if ! test -f "$1"; then
    echo "Error: $1 does not exist."
    JOB_RESULT=1
    exit 1
  fi
}

setup_vpn() {
  # this fails in local environment because we already have the tun interface because of is installed in the host
  mknod /dev/net/tun c 10 200 || true
  chmod 600 /dev/net/tun

  echo "${OPENVPN_USER}" > /tmp/auth.txt
  echo "${OPENVPN_PASSWORD}" >> /tmp/auth.txt

  cat "/var/cert.openvpn" | base64 -d > /tmp/config.ovpn

  openvpn --config "/tmp/config.ovpn" --auth-user-pass "/tmp/auth.txt" --script-security 3  --daemon
}

git_commit_push() {
  # Mitigate the git commit error since GIT_COMMITTER_NAME and GIT_COMMITTER_EMAIL are not used during the commit command
  GIT_AUTHOR_NAME=${GIT_COMMITTER_NAME}
  GIT_AUTHOR_EMAIL=${GIT_COMMITTER_EMAIL}
  CLUSTER_CREATION_STATUS="success"
  if [ $? -ne 0 ] || [ ${JOB_RESULT} -ne 0 ]; then CLUSTER_CREATION_STATUS="failure"; fi

  git pull --rebase --autostash
  git add ${BASE_WORKDIR}
  git commit -m "Create cluster ${CLUSTER_FULL_NAME}: ${CLUSTER_CREATION_STATUS}"
  git push
}

handle_exit() {
  notify_error

  if [[ ${SHOULD_COMMIT_AND_PUSH} -eq 1 ]]; then
    git_commit_push
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
  if [ $? -ne 0 ] || [ ${JOB_RESULT} -ne 0 ]; then
    notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* creation has failed :flushed:\"}}]}"
  fi
}

notify_start() {
  notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Starting creation of cluster *${CLUSTER_FULL_NAME}* :hammer_and_wrench:\"}}]}"
}

notify_finish() {
  notify "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_FULL_NAME}* has been created :tada:\"}}]}"
}

trap handle_exit EXIT

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
    check_env_variable OPENVPN_USER
    check_env_variable OPENVPN_PASSWORD
    setup_vpn
  ;;
  "gcp")
    # GCP
    check_env_variable GOOGLE_CREDENTIALS
    check_env_variable OPENVPN_USER
    check_env_variable OPENVPN_PASSWORD
    setup_vpn
  ;;
  *)
    # ERROR
    echo "Provider $PROVIDER_NAME not supported"
    JOB_RESULT=1
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

SHOULD_COMMIT_AND_PUSH=1
# ------------------------------------------
# Launch furyctl
# ------------------------------------------
echo "🚀  starting cluster creation"
cp /var/cluster.yml ${WORKDIR}/cluster.yml

furyctl cluster init --reset --no-tty

# Create terraform and ansible log files, and stream their output

mkdir -p ${WORKDIR}/cluster/logs

touch ${WORKDIR}/cluster/logs/terraform.logs
touch ${WORKDIR}/cluster/logs/ansible.log

tail -f ${WORKDIR}/cluster/logs/terraform.logs &
tail -f ${WORKDIR}/cluster/logs/ansible.log &

# Sometimes in vSphere the apply failing with apparently no reason, and re-launching it, it ends successfully
retry_command "furyctl cluster apply --no-tty" 10 3

# ------------------------------------------
# Install Fury
# ------------------------------------------

echo "🐉  deploying Kubernetes Fury Distribution"

export KUBECONFIG=${WORKDIR}/cluster/secrets/users/admin.conf

# Download Fury modules
cp /var/Furyfile.yml ${WORKDIR}/Furyfile.yml
retry_command "furyctl vendor --https --no-tty" 6 3

# Copy presets ("manifests templates") to cluster folder
cp -r ${BASE_WORKDIR}/presets ${WORKDIR}/manifests

# Update the ingress hostname accordingly
grep -rl '{{INGRESS_BASE_URL}}' manifests | xargs sed -i s/{{INGRESS_BASE_URL}}/${INGRESS_BASE_URL}/

# Update the cluster cidr in the networking patch using the info from cluster.yml
# We use ~ as separator instead of / to avoid the confusion with the slash in the network cidr
CLUSTER_POD_CIDR=$(yq eval .spec.clusterPODCIDR /var/cluster.yml)
sed -i s~{{CALICO_IPV4POOL_CIDR}}~${CLUSTER_POD_CIDR}~ manifests/modules/networking/patches/calico-ds.yml

# TODO: remove the following line once the module gets tagged, as we are going to vendor it
sed -i s~{{KARRIER_MODULE_VERSION}}~${KARRIER_MODULE_VERSION}~ manifests/modules/karrier/kustomization.yaml

# deploy common modules
echo "👘 dressing the cluster with Fury modules"
retry_command "kustomize build manifests/modules | kubectl apply -f -" 10 4

# deploy provider-specific modules
if [ -d "manifests/providers/${PROVIDER_NAME}" ]; then
  echo "🍷 applying ${PROVIDER_NAME}-specific customizations"
  retry_command "kustomize build 'manifests/providers/${PROVIDER_NAME}' | kubectl apply -f -" 10 4
fi

# Waiting for master node to be ready
echo "⏱  waiting for master node to be ready... "
kubectl wait --for=condition=Ready nodes/${CLUSTER_FULL_NAME}-master-1.localdomain --timeout 5m

# This is a workaround because we have a random issue on vSphere that sometimes doesn't find the nodes
for node in $(kubectl get nodes -ojsonpath='{.items[*].metadata.name}'); do
  kubectl taint node ${node} node.cloudprovider.kubernetes.io/uninitialized-
done

echo
echo "we're done! enjoy your cluster 🎉"
echo

notify_finish
