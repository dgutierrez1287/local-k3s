#!/usr/bin/env bash

# Args
repo_dir=$1
machine=$2
up_type=$3

if [ "${machine}" == "all" ]; then
  echo "Spinning up all the machines in the multi-node cluster"

  pushd "${repo_dir}/multi-node"
   vagrant up ${up_type}
  popd
else
  echo "Spinning up machine ${machine} in the multi-node cluster"

  pushd "${repo_dir}/multi-node"
    vagrant up ${machine}
  popd
fi
