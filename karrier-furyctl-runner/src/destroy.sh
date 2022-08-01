#!/bin/bash

set -a
set -e
set -o pipefail
set -u

# Basic ENV VARS
SHOULD_COMMIT_AND_PUSH=0
JOB_RESULT=0
BASE_WORKDIR="/workdir"
START_TIME=$(date +"%s")

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

  retry_command 'openvpn --config "/tmp/config.ovpn" --auth-user-pass "/tmp/auth.txt" --script-security 3  --daemon' 20 4
}

git_commit_push() {
  # Mitigate the git commit error since GIT_COMMITTER_NAME and GIT_COMMITTER_EMAIL are not used during the commit command
  GIT_AUTHOR_NAME=${GIT_COMMITTER_NAME}
  GIT_AUTHOR_EMAIL=${GIT_COMMITTER_EMAIL}
  CLUSTER_CREATION_STATUS="success"
  if [ $? -ne 0 ] || [ ${JOB_RESULT} -ne 0 ]; then CLUSTER_CREATION_STATUS="failure"; fi

  retry_command "git pull --rebase --autostash" 20 4
  git add ${BASE_WORKDIR}
  git commit -m "Create cluster ${CLUSTER_FULL_NAME}: ${CLUSTER_CREATION_STATUS}"
  retry_command "git push" 20 4
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

# KFD Karrier Module
check_env_variable KARRIER_MODULE_VERSION

# GIT Repository
check_env_variable GIT_REPO_URL
check_env_variable GIT_COMMITTER_NAME
check_env_variable GIT_COMMITTER_EMAIL

# Furyctl
check_env_variable FURYCTL_TOKEN
check_env_variable CLUSTER_SLUG
check_env_variable CLUSTER_ENVIRONMENT
check_env_variable CLUSTER_UUID

# Slack
check_env_variable SLACK_TOKEN
check_env_variable SLACK_CHANNEL

# INGRESS_BASE_URL for creating the patches
check_env_variable INGRESS_BASE_URL

# Auxiliary ENV VARS
CLUSTER_FULL_NAME="${CLUSTER_SLUG}-${CLUSTER_ENVIRONMENT}"
WORKDIR="${BASE_WORKDIR}/${CLUSTER_SLUG}-${CLUSTER_UUID}"

case $PROVIDER_NAME in
  "vsphere")
    # vSphere
    check_env_variable VSPHERE_USER
    check_env_variable VSPHERE_PASSWORD
    check_env_variable VSPHERE_SERVER
    check_env_variable VSPHERE_PORT
    check_env_variable VSPHERE_INSECURE_FLAG
    check_env_variable VSPHERE_DATACENTERS
    check_env_variable VSPHERE_DATASTORE_NAME
    check_env_variable VSPHERE_FOLDER

    GOVC_URL="https://${VSPHERE_SERVER}"
    GOVC_DATACENTER="${VSPHERE_DATACENTERS}"
    GOVC_INSECURE="${VSPHERE_INSECURE_FLAG}"
    GOVC_USERNAME="${VSPHERE_USER}"
    GOVC_PASSWORD="${VSPHERE_PASSWORD}"
    GOVC_DATASTORE="${VSPHERE_DATASTORE_NAME}"

    LOCAL_KUBECONFIG="${WORKDIR}/cluster/secrets/users/admin.conf"
  ;;
  "aws")
    # AWS
    check_env_variable AWS_ACCESS_KEY_ID
    check_env_variable AWS_SECRET_ACCESS_KEY
    check_env_variable OPENVPN_USER
    check_env_variable OPENVPN_PASSWORD
    setup_vpn

    LOCAL_KUBECONFIG="${WORKDIR}/cluster/secrets/kubeconfig"
  ;;
  "gcp")
    # GCP
    check_env_variable GOOGLE_APPLICATION_CREDENTIALS
    check_env_variable GOOGLE_PROJECT
    check_env_variable GOOGLE_REGION
    check_env_variable OPENVPN_USER
    check_env_variable OPENVPN_PASSWORD
    setup_vpn

    #this is necessary because we receive a base64 encoded json
    echo "${GOOGLE_APPLICATION_CREDENTIALS}" | base64 -d > /tmp/credentials.json
    export GOOGLE_APPLICATION_CREDENTIALS="/tmp/credentials.json"

    #TODO: we have to check if in GKE is this the right kubeconfig path
    LOCAL_KUBECONFIG="${WORKDIR}/cluster/secrets/kubeconfig"
  ;;
  *)
    # ERROR
    echo "Provider $PROVIDER_NAME not supported"
    JOB_RESULT=1
    exit 1
  ;;
esac

echo "OK."

# Let's start!

notify_start

# Create .netrc file to make authenticated git requests
echo "machine github.com login ${CLUSTER_ENVIRONMENT} password ${FURYCTL_TOKEN}" > ~/.netrc

# -------------------------------------------------------------------------
# Clone the repo where we'll put all the stuff and cd into it
# -------------------------------------------------------------------------

retry_command "git clone ${GIT_REPO_URL} ${BASE_WORKDIR}" 10 4

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
# Destroy the loadbalancer if it exists
# ------------------------------------------

# we need some missing components on provider side because of need to communicate with the metadata api inside the
# cluster
if [ -d "terraform/providers/${PROVIDER_NAME}" ]; then
  cd terraform/providers/${PROVIDER_NAME}
  instance_filter="k8s.io/cluster/${CLUSTER_SLUG}"
  terraform init
  retry_command "TF_VAR_fqdn=${INGRESS_BASE_URL} TF_VAR_instance_filter=${instance_filter} terraform destroy -auto-approve" 10 4
  cd -
fi


# ------------------------------------------
# Launch furyctl
# ------------------------------------------
touch ${WORKDIR}/cluster/logs/terraform.logs
touch ${WORKDIR}/cluster/logs/ansible.log

tail -f ${WORKDIR}/cluster/logs/terraform.logs &
tail -f ${WORKDIR}/cluster/logs/ansible.log &

retry_command "furyctl cluster destroy --force" 10 3

echo
echo "we're done! the cluster was deleted successfully 💣"
echo

notify_finish
