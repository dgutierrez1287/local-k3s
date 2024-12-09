#!/usr/bin/env bash

# Args
repo_dir=$1

pushd "${repo_dir}/multi-node"
  vagrant rsync
popd
