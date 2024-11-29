#!/usr/bin/env bash

# Args
repo_dir=$1 
direction=$2 # up or down, used to add or remove from kubeconfig

if [ "${direction}" == "up" ]; then

  pushd "${repo_dir}/single-node"
    echo "Adding kubeconfig as local-single-node context"
    kubectl-kc add -f kubeconfig/config.yaml --context-name local-single-node  
  popd

elif [ "${direction}" == "down" ]; then 
  
  pushd "${repo_dir}/single-node"
    echo "Removing the local-single-node context"
    kubectl-kc delete local-single-node
    rm -f kubeconfig/config.yaml
  popd

else 
  echo "unknown direction"
  exit 123
fi
