#!/usr/bin/env bash

# Args 
repo_dir=$1 

echo "Destroying the single node k3s cluster"

pushd "${repo_dir}/single-node"

vagrant destroy -f

popd
