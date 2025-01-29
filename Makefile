# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

machine := "cp01"
up-type := "no-parallel"

# Detect OS
OS := $(shell uname)

help:
	@echo "Local K3s Control"
	@echo "==================================="
	@echo "list-vars: Lists generic variables"
	@echo "pull-role: pulls the k3s role from the configured location"
	@echo "prep: preps the cluster putting in place needed files and folders (this should only be needed once)" 
	@echo "status: shows the status for both cluster types"
	@echo ""
	@echo "Single Node Control"
	@echo "==========================================="
	@echo "sn-machine-up: brings up a single-node cluster machine"
	@echo "sn-up: spins up a single-node local cluster and does all provisioning"
	@echo "sn-machine-down: destroys a single-node cluster machine"
	@echo "sn-down: destroys a running single-node local cluster and cleans up"
	@echo "sn-ssh: SSH into the single node local cluster"
	@echo "sn-sync: Syncs the shared folders"
	@echo "sn-provision: runs ansible on the single node local cluster"
	@echo "sn-reset: resets all the settings for the single node cluster"
	@echo "sn-add-kubeconfig: adds the local single node config to users context"
	@echo "sn-clear-kubeconfig: removes the local single node config from users context"
	@echo ""
	@echo "Multi Node Control"
	@echo "============================================"
	@echo "mn-machine-up machine=<name>: brings up one machine in the multinode cluster"
	@echo "mn-machine-up-all: brings up all the machines in the multi node cluster"
	@echo "mn-up: spins up a multi-node local cluster"
	@echo "mn-machine-down-all: destroys all the machines in the multi node cluster"
	@echo "mn-down: destroys a running multi-node local cluster"
	@echo "mn-ssh machine=<name>: SSH into the selected machine"
	@echo "mn-sync: Syncs shared folders"
	@echo "mn-machine-provision machine=<name>: runs ansible for only a selected machine"
	@echo "mn-provision: runs a full provision on all nodes"
	@echo "mn-reset: resets all the settings for a multi node cluster"
	@echo "mn-add-kubeconfig: adds the multinode kubeconfig to users context"
	@echo "mn-clear-kubeconfig: removes the multi node config from the users context"
	

## General ##

pull-role:
	/usr/bin/env bash scripts/local/pull_role.sh "${MAKEFILE_DIR}" "kube"

list-vars:
	@echo "OS Type: ${OS}"
	@echo "Repo dir: ${MAKEFILE_DIR}"

prep:
	/usr/bin/env bash scripts/local/prep_reset.sh "${MAKEFILE_DIR}" "prep" "none"

status:
	/usr/bin/env bash scripts/local/status.sh "${MAKEFILE_DIR}"

## Single Node ##

sn-machine-up: pull-role
	/usr/bin/env bash scripts/local/single_node/up.sh "${MAKEFILE_DIR}"

sn-up: pull-role sn-machine-up sn-provision sn-add-kubeconfig

sn-machine-down: 
	/usr/bin/env bash scripts/local/single_node/down.sh "${MAKEFILE_DIR}"

sn-down: sn-machine-down sn-clear-kubeconfig

sn-ssh:
	/usr/bin/env bash scripts/local/single_node/ssh.sh "${MAKEFILE_DIR}"

sn-sync:
	/usr/bin/env bash scripts/local/single_node/sync.sh "${MAKEFILE_DIR}"

sn-provision: pull-role sn-sync
	/usr/bin/env bash scripts/local/single_node/provision.sh "${MAKEFILE_DIR}"

sn-reset:
	/usr/bin/env bash scripts/local/prep_reset.sh "${MAKEFILE_DIR}" "reset" "single-node"

sn-add-kubeconfig:
	/usr/bin/env bash scripts/local/single_node/local_kubeconfig.sh "${MAKEFILE_DIR}" "up"

sn-clear-kubeconfig:
	/usr/bin/env bash scripts/local/single_node/local_kubeconfig.sh "${MAKEFILE_DIR}" "down"

## Multi Node ##

mn-machine-up: pull-role
	/usr/bin/env bash scripts/local/multi_node/up.sh "${MAKEFILE_DIR}" "${machine}"

mn-machine-up-all: pull-role
	/usr/bin/env bash scripts/local/multi_node/up.sh "${MAKEFILE_DIR}" "all" "--${up-type}"

mn-up: pull-role mn-machine-up-all mn-provision mn-add-kubeconfig

mn-down: mn-machine-down-all mn-clear-kubeconfig

mn-machine-down-all:
	/usr/bin/env bash scripts/local/multi_node/down.sh "${MAKEFILE_DIR}"

mn-ssh:
	/usr/bin/env bash scripts/local/multi_node/ssh.sh "${MAKEFILE_DIR}" "${machine}"

mn-sync:
	/usr/bin/env bash scripts/local/multi_node/sync.sh "${MAKEFILE_DIR}"

mn-provision: 
	/usr/bin/env bash scripts/local/multi_node/provision.sh "${MAKEFILE_DIR}" "all"

mn-reset:
	/usr/bin/env bash scripts/local/prep_reset.sh "${MAKEFILE_DIR}" "reset" "multi-node"

mn-add-kubeconfig:
	/usr/bin/env bash scripts/local/multi_node/local_kubeconfig.sh "${MAKEFILE_DIR}" "up"

mn-clear-kubeconfig:
	/usr/bin/env bash scripts/local/multi_node/local_kubeconfig.sh "${MAKEFILE_DIR}" "down"
