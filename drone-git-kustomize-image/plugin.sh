#!/bin/sh

set -eo pipefail
cd /tmp

git clone $PLUGIN_REPOSITORY

cd $PLUGIN_REPOSITORY/$PLUGIN_FOLDER

git checkout $PLUGIN_TARGET_BRANCH

kustomize edit set imagetag $PLUGIN_IMAGE:$PLUGIN_SHA
if [ -n "$PLUGIN_IMAGE_2" ];then
  kustomize edit set imagetag $PLUGIN_IMAGE_2:$PLUGIN_SHA_2
fi
if [ -n "$PLUGIN_IMAGE_3" ];then
  kustomize edit set imagetag $PLUGIN_IMAGE_3:$PLUGIN_SHA_3
fi
if [ -n "$PLUGIN_IMAGE_4" ];then
  kustomize edit set imagetag $PLUGIN_IMAGE_4:$PLUGIN_SHA_4
fi
if [ -n "$PLUGIN_IMAGE_5" ];then
  kustomize edit set imagetag $PLUGIN_IMAGE_5:$PLUGIN_SHA_5
fi

git add .

git commit -m "${PLUGIN_COMMIT_MESSAGE}"

git push