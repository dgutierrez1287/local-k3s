#!/usr/bin/env bash

# Args
repo_dir=$1

pushd "${repo_dir}/single-node"
  vagrant ssh -c "bash /vagrant/scripts/single_node/provision.sh"
popd
