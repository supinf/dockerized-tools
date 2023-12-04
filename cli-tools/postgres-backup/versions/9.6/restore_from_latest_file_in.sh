#!/bin/sh
set -e

echo "get latest file from ${S3_BUCKET}/${RESTORE_FROM_LATEST_FILE_IN}"
# the number of objects in the prefix need to be less than 1000. 
# https://docs.aws.amazon.com/cli/latest/reference/s3api/list-objects.html
LATEST_FILE_KEY=$(aws s3api list-objects --bucket ${S3_BUCKET} --prefix ${RESTORE_FROM_LATEST_FILE_IN} --query "max_by(Contents, &LastModified).Key" --output text)

echo "downloading latest file ${LATEST_FILE_KEY}"

aws s3 cp "s3://${S3_BUCKET}/${LATEST_FILE_KEY}" dump.sql.gz || exit 2
sleep 1
gzip -d dump.sql.gz

echo "Restore to ${POSTGRES_DATABASE} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"
export PGPASSWORD=$POSTGRES_PASSWORD
psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
    "${POSTGRES_DATABASE}" < dump.sql
