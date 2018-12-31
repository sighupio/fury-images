#!/usr/bin/env bats
NAME=$(date +%s)
set -e
setup () {
  if [[ "$BATS_TEST_NUMBER" -eq 1 ]]
  then
    echo "# creating cluster $NAME" >&3
    kind create cluster --name "$NAME" --config /kind-config --wait 1m >&3
    export KUBECONFIG="$(kind get kubeconfig-path --name="$NAME")"
    sed -i 's/localhost/'"$CLUSTER_HOST"'/g' "$KUBECONFIG"
    echo "# created cluster $NAME" >&3
  fi
}

teardown() {
  if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]
  then
    echo "# deleting cluster $NAME" >&3
    kind delete cluster --name="$NAME"
    echo "# deleted cluster $NAME" >&3
  fi
}

test_apply() {
  kubectl get nodes >&3
  pwd >&3
  ls >&3
  e=0
  for el in $DIRS; do
      echo "# applying $el" >&3
      kustomize build $BASEDIR/$el | (kubectl apply -f -) 2>&1 >&3 || e=$? && echo "# e=$e" >&3
  done
  kubectl get all --all-namespaces >&3
  return $e
}

@test "testing apply to cluster" {
  run test_apply
  [ "$status" -eq 0 ]
}
