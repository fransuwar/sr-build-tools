#!/usr/bin/env bash

export initial_folder=$1
export destination_folder=$2
export levels_depth=$3
export github_user=${4:-github_user_not_provided}
export github_password=${5:-github_password_not_provided}

export current_folder=$initial_folder
cd $destination_folder

wstool init .

export rosinstall_filename="repository.rosinstall"

export current_repo_count=$(find $destination_folder -type f -name $rosinstall_filename | wc -l)
export previous_repo_count=-1
export loops_count=$((levels_depth - 1))

while [ $current_repo_count -ne $previous_repo_count ]; do
  find $current_folder -type f -name $rosinstall_filename -exec sed '$a\#' {} \; | sed -e "s/{{github_login}}/$github_user/g" | sed -e "s/{{github_password}}/$github_password/g" | wstool merge -a -y -
  wstool update --delete-changed-uris  -j5

  export previous_repo_count=$current_repo_count
  export current_repo_count=$(find $destination_folder -type f -name $rosinstall_filename | wc -l)

  if [ $loops_count -ge 1 ]; then
    export loops_count=$((loops_count - 1))
  else
    break
  fi
  export current_folder=$destination_folder

done

