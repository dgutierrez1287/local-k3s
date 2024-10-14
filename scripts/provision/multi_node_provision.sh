#!/usr/bin/env bash

machine_name="$(hostname)"
primary_control="$(yq eval '.primary-control' /vagrant/settings.yaml)"

if [[ "${machine_name}" == "${primary_control}" ]]; then
  echo "this is the primary control machine and will ansible host also"

  echo "installing ansible"
  bash /provision/ansible-bootstrap.sh

  echo "setting up ansible hosts"
  bash /provision/ansible-hosts.sh "multi_node"

else
  echo "this is not the primary control machine"
fi

exit 0
