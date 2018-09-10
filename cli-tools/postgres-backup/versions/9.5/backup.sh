#!/bin/sh
set -e

echo "Creating dump of ${POSTGRES_DATABASE} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"

export PGPASSWORD=$POSTGRES_PASSWORD
pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
  $POSTGRES_EXTRA_OPTS "${POSTGRES_DATABASE}" | gzip > dump.sql.gz

echo "Uploading the dump to ${S3_BUCKET}"

now=$(date +"%Y-%m-%dT%H:%M:%SZ")
key="s3://${S3_BUCKET}/${S3_PREFIX}${POSTGRES_DATABASE}_${now}.sql.gz"

if [ "${SERVER_SIDE_ENCRYPTION}" = "true" ]; then
  if [ "x${KMS_KEY_ID}" = "x" ]; then
    aws s3 cp --sse AES256 dump.sql.gz "${key}" || exit 2
  else
    aws s3 cp --sse aws:kms --sse-kms-key-id "${KMS_KEY_ID}" dump.sql.gz "${key}" || exit 2
  fi
else
  aws s3 cp dump.sql.gz "${key}" || exit 2
fi

echo "Uploaded successfully"
