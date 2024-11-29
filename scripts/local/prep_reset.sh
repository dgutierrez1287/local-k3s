#!/usr/bin/env bash

# ARGS
repo_dir=$1 # The fully pathed dir for the top of the repo
run_type=$2 # prep or reset
cluster_type=$3 # The type of cluster to prep

if [ "${run_type}" == "prep" ]; then
  echo "Prepping both single and multi-node clusters"

  echo "Prepping single node"
  pushd "${repo_dir}/single-node"
    mkdir kubeconfig

    touch ansible-vars.yml
    echo "---" > ansible-vars.yml
    echo " " >> ansible-vars.yml

    cp settings.yaml.example settings.yaml
  popd

  echo "Prepping multi node"
  pushd "${repo_dir}/multi-node"
    mkdir kubeconfig

    touch ansible-vars.yml
    echo "---" > ansible-vars.yml
    echo " " >> ansible-vars.yml

    cp settings.yaml.example settings.yaml
  popd

  echo "Prepping global"
  cp global_settings.yaml.example global_settings.yaml
else 

  while true; do
    read -p "Are you sure you want to reset ${cluster_type}?" yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) echo "answer no, exiting"; exit;;
      * ) echo "Please answer yes or no";;
    esac
  done

  if [[ "${cluster_type}" == "multi-node" ]]; then
    echo "Resetting multi-node cluster settings"
    pushd "${repo_dir}/multi-node"
      # clear out kubeconfig dir
      rm -f kubeconfig/*

      # reset settings
      rm -f settings.yaml
      cp settings.yaml.example settings.yaml
      
      # reset user ansible vars
      rm -f ansible-vars.yml
      touch ansible-vars.yml
      echo "---" > ansible-vars.yml
      echo " " >> ansible-vars.yml


    popd

  elif [[ "${cluster_type}" == "single-node" ]]; then
    echo "Resetting single-node cluster settings"
    pushd "${repo_dir}/single-node"
      # clear out kubeconfig dir
      rm -f kubeconfig/*
      
      # reset settings
      rm -f settings.yaml
      cp settings.yaml.example settings.yaml
      
      # reset user ansible vars
      rm -f ansible-vars.yml
      touch ansible-vars.yml
      echo "---" > ansible-vars.yml
      echo " " >> ansible-vars.yml

    popd

  else
    echo "unknown cluster type"
  fi
fi
