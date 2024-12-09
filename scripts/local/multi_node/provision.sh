#!/usr/bin/env bash

# Args
repo_dir=$1

pushd "${repo_dir}/multi-node"
  lead_node=$(yq e '.lead-control-node[0].name' settings.yaml)
  vagrant ssh ${lead_node} -c "bash /vagrant/scripts/provision.sh"
popd
