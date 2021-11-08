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
        message="{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}* has been destroyed :skull: \"}}]}"
    else
        message="{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Your cluster *${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}* destruction has failed :flushed:\"}}]}"
    fi

    echo "📬  sending Slack notification... "

    curl -H "Content-type: application/json" \
    --data  "${message}" \
    -H "Authorization: Bearer ${SLACK_TOKEN}" \
    --output /dev/null -s \
    -X POST https://slack.com/api/chat.postMessage

    exit ${JOB_RESULT}
}

export JOB_RESULT=0

BASE_WORKDIR="/workdir"

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

echo "OK."

# Let's start!

echo "📬  sending Slack notification... "
curl -H "Content-type: application/json" \
--data "{\"channel\":\"${SLACK_CHANNEL}\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Starting destruction of cluster *${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}* 💣 \"}}]}" \
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

WORKDIR="${BASE_WORKDIR}/${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}"

echo "switching to workdir: ${WORKDIR}"
cd $WORKDIR

# ------------------------------------------
# Launch furyctl destroy
# ------------------------------------------
echo "🚀  starting cluster destruction"

furyctl cluster destroy --force

# We launch the command twice as sometimes fails at the end
# TODO: Fix this behaviour
furyctl cluster destroy --force
if [ $? -ne 0 ]; then
    JOB_RESULT=1
    notify
fi

# ------------------------------------------
# Push to repository our changes
# ------------------------------------------

cd ${BASE_WORKDIR}
git pull --rebase --autostash
git rm -r ${WORKDIR}
git commit -m "Destroy cluster ${CLUSTER_NAME}-${CLUSTER_ENVIRONMENT}"
git push
if [ $? -ne 0 ]; then
    JOB_RESULT=1
fi

# FINISH

echo
echo "we're done! cluster deleted 💀"
echo

notify
