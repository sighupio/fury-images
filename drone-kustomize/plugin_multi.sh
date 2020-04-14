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
if [ -n "$PLUGIN_IMAGE_2" ]
  kustomize edit set imagetag $PLUGIN_IMAGE_2:$PLUGIN_SHA_2
fi
if [ -n "$PLUGIN_IMAGE_3" ]
  kustomize edit set imagetag $PLUGIN_IMAGE_3:$PLUGIN_SHA_3
fi
if [ -n "$PLUGIN_IMAGE_4" ]
  kustomize edit set imagetag $PLUGIN_IMAGE_4:$PLUGIN_SHA_4
fi
if [ -n "$PLUGIN_IMAGE_5" ]
  kustomize edit set imagetag $PLUGIN_IMAGE_5:$PLUGIN_SHA_5
fi
kustomize build | kubectl apply -f-
