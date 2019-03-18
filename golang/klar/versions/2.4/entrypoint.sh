#!/bin/sh

if [ "${AWS_ACCESS_KEY_ID}" != "" ]; then
  DOCKER_USER=AWS
  DOCKER_PASSWORD=$( ecr-creds get password )
  export DOCKER_USER
  export DOCKER_PASSWORD
fi

exec klar "$@"
