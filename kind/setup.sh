#!/usr/bin/env bash
kind create cluster --name "$NAME" --config /kind-config --wait 1m
export KUBECONFIG="$(kind get kubeconfig-path --name="$NAME")"
sed -i 's/localhost/'"$CLUSTER_HOST"'/g' "$KUBECONFIG"
