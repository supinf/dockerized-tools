#!/bin/sh

export target_file=$1
if [ -z "$target_file" ]; then
  echo 'A target file path must be passed.' 1>&2
  exit 1
fi

export env_file=$2
if [ -e "$env_file" ]; then
  set -o allexport
  source $env_file
fi

envsubst < $target_file
