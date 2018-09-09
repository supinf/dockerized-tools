#!/bin/sh

if [ "x${POSTGRES_DATABASE}" = "x" ]; then
  echo "You need to specify POSTGRES_DATABASE as an environment variable."
  exit 1
fi
if [ "x${POSTGRES_HOST}" = "x" ]; then
  echo "You need to specify POSTGRES_HOST as an environment variable."
  exit 1
fi
if [ "x${S3_BUCKET}" = "x" ]; then
  echo "You need to specify S3_BUCKET as an environment variable."
  exit 1
fi

if [ "x${SCHEDULE}" = "x" ]; then
  sh backup.sh
else
  exec go-cron -s "${SCHEDULE}" -p 10080 -- /bin/sh backup.sh
fi
