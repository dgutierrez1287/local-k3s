#!/usr/bin/env bash

# Args
repo_dir=$1 # the fully pathed dir for the top of the repo

echo "Spinning up a single node k3s cluster"

pushd "${repo_dir}/single-node"

vagrant up

popd


