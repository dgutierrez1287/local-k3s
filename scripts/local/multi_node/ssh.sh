#!/usr/bin/env bash

# Args
repo_dir=$1
machine=$2

pushd "${repo_dir}/multi-node"
  vagrant ssh ${machine}
popd
