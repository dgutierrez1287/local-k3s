#!/usr/bin/env bash

# add space to /etc/hosts
echo "" >> /etc/hosts

# get machine hostname
machine_name="${hostname}"

# get list of control nodes into array
readarray cpNodes < <(yq e -o=j -I=0 '.control-nodes[]' /vagrant/settings.yaml)

# get list of worker nodes into array
readarray wNodes < <(yq e -o=j -I=0 '.workers[]' /vagrant/settings.yaml)

# loop through control nodes to add to hosts file
for cp in "${cpNodes[@]}"; do
  name=$(echo "$cp" | yq e '.name' -)
  ip=$(echo "$cp" | yq e '.ip' -)

  if [ "${name}" != "${machine_name}" ]; then
    echo "${ip}  ${name}" >> /etc/hosts
  fi
done

# loop through worker nodes to add to hosts file
for w in "${wNodes[@]}"; do
  name=$(echo "$w" | yq e '.name' -)
  ip=$(echo "$w" | yq e '.ip' -)

  if [ "${name}" != "${machine_name}" ]; then
    echo "${ip}  ${name}" >> /etc/hosts
  fi
done

# add cluster ip to hosts
cluster_vip=$(yq e '.cluster-vip' /vagrant/settings.yaml)
cluster_name=$(yq e '.cluster-name' /vagrant/settings.yaml)
echo "${cluster_vip}  ${cluster_name}" >> /etc/hosts

exit 0
