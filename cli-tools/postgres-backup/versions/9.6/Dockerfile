# postgres-backup
# docker run --rm -it -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=ap-northeast-1 -e POSTGRES_HOST=192.168.x.x -e S3_BUCKET=my-bucket ghcr.io/supinf/postgres-backup:9.6

FROM alpine:3.18

ENV SCHEDULE= \
    POSTGRES_DATABASE= \
    POSTGRES_HOST= \
    POSTGRES_PORT=5432 \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD= \
    POSTGRES_EXTRA_OPTS= \
    AWS_DEFAULT_REGION=us-west-1 \
    S3_BUCKET= \
    S3_PREFIX= \
    SERVER_SIDE_ENCRYPTION=true \
    KMS_KEY_ID= \
    RESTORE_AFTER= \
    RESTORE_FROM= \
    RESTORE_FROM_LATEST_FILE_IN=

RUN apk --no-cache add postgresql curl aws-cli

RUN curl -L https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz \
       | zcat > /usr/local/bin/go-cron \
    && chmod +x /usr/local/bin/go-cron

ADD entrypoint.sh /
ADD restore.sh /
ADD backup.sh /
ADD restore_from_latest_file_in.sh /
RUN chmod +x /entrypoint.sh /restore.sh /backup.sh /restore_from_latest_file_in.sh
ENTRYPOINT ["/entrypoint.sh"]
