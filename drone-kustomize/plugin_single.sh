#!/bin/sh

set -euo pipefail
cd $PLUGIN_BASEPATH

if [ -n "$PLUGIN_KUBECONFIG" ];then
    [ -d $HOME/.kube ] || mkdir $HOME/.kube
    echo "# Plugin PLUGIN_KUBECONFIG available" >&2
    echo "$PLUGIN_KUBECONFIG" > $HOME/.kube/config
    unset PLUGIN_KUBECONFIG
fi

kustomize build > /dev/null
kustomize edit set imagetag $PLUGIN_IMAGE:$PLUGIN_SHA
kustomize build | kubectl apply -f-
