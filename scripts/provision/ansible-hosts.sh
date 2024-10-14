#!/usr/bin/env bash

cluster_type=$1 # set the cluster type to set the ansible hosts on

if [[ "$cluster_type" == "single_node"  ]]; then
  echo "setting ansible for single node"

  echo "localhost ansible_connection=local" > /etc/ansible/hosts

elif [[ "$cluster_type" == "multi_node" ]]; then
  echo "setting ansible for multi node"

  machine_name="${hostname}"
  primary_control=$(yq e '.primary-control' /vagrant/settings.yaml)

  readarray cpNodes < <(yq e -o=j -I=0 '.control-nodes[]' /vagrant/settings.yaml)

  # write out the control-nodes group and the primary (this node) as a local connection
  echo "[control-nodes]" >> /etc/ansible/hosts
  echo "${primary_control} ansible_connection=local" >> /etc/ansible/hosts
  
  # loop through control nodes to add to ansible hosts
  for cp in "${cpNodes[@]}"; do 
    name=$(echo "$cp" | yq e '.name' -)

    if [[ "${name}" != "${primary_control}" ]]; then
      # write out the other control-nodes and specify connection details
      echo "${name}   ansible_connection=ssh  ansible_user=vagrant" >> /etc/ansible/hosts
    fi
  done

  readarray wNodes < <(yq e -o=j -I=0 '.workers[]' /vagrant/settings.yaml)

  # write out header for the the workers group
  echo " " >> /etc/ansible/hosts
  echo "[workers]" >> /etc/ansible/hosts
  
  # loop through worker nodes to add to ansible hosts
  for w in "${wNodes[@]}"; do
    name=$(echo "$w" | yq e '.name' -)

    # write out the worker nodes and the connection details
    echo "${name}   ansible_connection=ssh  ansible_user=vagrant" >> /etc/ansible/hosts
  done


else 
  echo "error unknown cluster type"
  exit 127
fi
