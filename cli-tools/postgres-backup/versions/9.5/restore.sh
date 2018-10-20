#!/bin/sh
set -e

echo "Restore to ${POSTGRES_DATABASE} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"

aws s3 cp "s3://${S3_BUCKET}/${RESTORE_FROM}" dump.sql.gz || exit 2
sleep 1
gzip -d dump.sql.gz

export PGPASSWORD=$POSTGRES_PASSWORD
psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
    "${POSTGRES_DATABASE}" < dump.sql
