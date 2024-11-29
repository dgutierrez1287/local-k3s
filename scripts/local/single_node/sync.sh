#!/usr/bin/env bash

# Args
repo_dir=$1

pushd "${repo_dir}/single-node"
  vagrant rsync
popd
