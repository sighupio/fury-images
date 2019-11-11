#!/usr/bin/env bash
echo "waiting for docker to start"
let i=0; while ! docker ps; do let i=i+1; [ $i -le 12 ] || exit 1 && sleep 5; done || exit 1
set -e
kind create cluster --name "$NAME" --config /kind-config --image kindest/node:${K8S_VERSION} --wait 1m --loglevel=debug
kind get kubeconfig --name "$NAME" > /kubeconfig
export KUBECONFIG=/kubeconfig
sed -i -E -e 's/localhost|0\.0\.0\.0/'"$CLUSTER_HOST"'/g' "$KUBECONFIG"
sleep 5
