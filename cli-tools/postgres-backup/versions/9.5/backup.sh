#!/bin/sh
set -e

echo "Creating dump of ${POSTGRES_DATABASE} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"

export PGPASSWORD=$POSTGRES_PASSWORD
pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
  $POSTGRES_EXTRA_OPTS "${POSTGRES_DATABASE}" | gzip > dump.sql.gz

echo "Uploading the dump to ${S3_BUCKET}"

now=$(date +"%Y-%m-%dT%H:%M:%SZ")
key="s3://${S3_BUCKET}/${S3_PREFIX}${POSTGRES_DATABASE}_${now}.sql.gz"
aws s3 cp dump.sql.gz "${key}" || exit 2

echo "Uploaded successfully"
