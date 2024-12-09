#!/usr/bin/env bash

# Args
repo_dir=$1

echo "single node status"
pushd "${repo_dir}/single-node"
  vagrant status
popd

echo " "
echo " "

echo "multi node status"
pushd "${repo_dir}/multi-node"
  vagrant status
popd
