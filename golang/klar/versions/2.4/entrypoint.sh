#!/bin/sh

if [ "${AWS_ACCESS_KEY_ID}" != "" ]; then
  export DOCKER_USER=AWS
  export DOCKER_PASSWORD=$( ecr-creds get password )
fi

exec klar "$@"
