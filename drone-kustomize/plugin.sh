#!/bin/sh

set -eo pipefail
cd $PLUGIN_BASEPATH

if [ -n "$PLUGIN_KUBECONFIG" ];then
    [ -d $HOME/.kube ] || mkdir $HOME/.kube
    echo "# Plugin PLUGIN_KUBECONFIG available" >&2
    echo "$PLUGIN_KUBECONFIG" > $HOME/.kube/config
    unset PLUGIN_KUBECONFIG
fi

kustomize build > /dev/null
if [ -n "$PLUGIN_IMAGE" ];then
  kustomize edit set image $PLUGIN_IMAGE:$PLUGIN_SHA # This command **doesn't change** the image specified in your manifests
fi
if [ -n "$PLUGIN_IMAGE_2" ];then
  kustomize edit set image $PLUGIN_IMAGE_2:$PLUGIN_SHA_2
fi
if [ -n "$PLUGIN_IMAGE_3" ];then
  kustomize edit set image $PLUGIN_IMAGE_3:$PLUGIN_SHA_3
fi
if [ -n "$PLUGIN_IMAGE_4" ];then
  kustomize edit set image $PLUGIN_IMAGE_4:$PLUGIN_SHA_4
fi
if [ -n "$PLUGIN_IMAGE_5" ];then
  kustomize edit set image $PLUGIN_IMAGE_5:$PLUGIN_SHA_5
fi
kustomize build | kubectl apply -f -

if [ -n "$PLUGIN_ROLLOUT_DEPLOYMENT" ];then
  kubectl rollout status deployment $PLUGIN_ROLLOUT_DEPLOYMENT -n $PLUGIN_ROLLOUT_NAMESPACE --timeout=${PLUGIN_ROLLOUT_TIMEOUT:-"180s"}
fi
