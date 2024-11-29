#!/usr/bin/env bash

# Args
repo_dir=$1 # the fully pathed dir for the top of the repo
role_name=$2 #-THe name of the role to pull

# get general settings
role_loc_type=$(yq e ".roles.${role_name}.location_type" "${repo_dir}/global_settings.yaml")
role_location=$(yq e ".roles.${role_name}.location" "${repo_dir}/global_settings.yaml")

echo "Role Name: ${role_name}"
echo "Role Location Type: ${role_loc_type}"
echo "Role Location: ${role_location}"

# get git specific settings
if [[ "${role_loc_type}" == "git" ]]; then
  role_git_branch=$(yq ".roles.${role_name}.git_branch" "${repo_dir}/global_settings.yaml")
  echo "Role Git Branch: ${role_git_branch}"
fi

if [[ "${role_loc_type}" == "local" ]]; then
  echo "cleaning current role"

  rm -rf "${repo_dir}/ansible/roles/${role_name}"

  echo "copying role from local filesystem location"

  mkdir -p "${repo_dir}/ansible/roles"
  cp -r "${role_location}" "${repo_dir}/ansible/roles/"

elif [[ "${role_loc_type}" == "git" ]]; then
  echo "cleaning current role"

  rm -rf "${repo_dir}/ansible/roles/k3s"

  echo "pulling role from git"

else
  echo "unknown role location type"
  exit 125
fi

exit 0




