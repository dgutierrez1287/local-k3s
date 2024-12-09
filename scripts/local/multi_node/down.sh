#!/usr/bin/env bash

# Args
repo_dir=$1

echo "destroying the multi-node cluster"

pushd "${repo_dir}/multi-node"
  vagrant destroy -f
popd
