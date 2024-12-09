#!/usr/bin/env bash

# Args
repo_dir=$1
direction=$2 # up or down, used to add or remove from the kubeconfig

if [ "${direction}" == "up" ]; then

  pushd "${repo_dir}/multi-node"
    echo "Adding kubeconfig as local-multi-node context"
    kubectl-kc add -f kubeconfig/config.yaml --context-name local-multi-node
  popd

elif [ "${direction}" == "down" ]; then

  pushd "${repo_dir}/multi-node"
    echo "Removing the local-multi-node context"
    kubectl-kc delete local-multi-node
    rm -f kubeconfig/config.yaml
  popd

else 
  echo "unknown direction"
  exit 123
fi
