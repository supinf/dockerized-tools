# Redash v8.0
# docker run --rm -p 5000:5000 supinf/redash:core-8.0

# git clone Redash
FROM ubuntu:xenial-20181005 AS build-git

ENV REDASH_VERSION=v8.0.0

WORKDIR /redash-git

RUN apt-get update 
RUN apt-get install -y git
RUN git clone --depth=1 -b ${REDASH_VERSION} https://github.com/getredash/redash.git /redash-git
RUN rm -rf tests old_migrations setup ./*.md ./*.yml ./.* 2>/dev/null | true

# Solve client dependencies build
FROM node:13.1.0-alpine AS build-client

COPY --from=build-git /redash-git /client
WORKDIR /client

RUN apk update
RUN apk add git
RUN npm install
RUN npm run build

# Solve server dependencies build
# @see https://github.com/getredash/docker/blob/master/base/Dockerfile

FROM ubuntu:xenial-20181005 AS build-server

COPY --from=build-git /redash-git /server
WORKDIR /server

RUN mkdir -p /var/cache/apt
RUN apt-get update
RUN apt-get install -y python libmysqlclient-dev python-pip libsasl2-dev libffi-dev libpq-dev libssl-dev
RUN pip install -U pip
RUN hash -r
RUN pip install -r requirements.txt -r requirements_all_ds.txt
RUN pip install -U setuptools==23.1.0
RUN apt-get remove --purge -y python-pip libsasl2-dev libffi-dev libpq-dev libssl-dev
RUN apt autoremove -y
RUN find / -type d -name tests -depth -exec rm -rf {} \;
RUN find / -type d -name test -depth -exec rm -rf {} \;
RUN find / -type d -name \__pycache__ -depth -exec rm -rf {} \;

# Redash v8.0 image
FROM ubuntu:xenial-20181005
COPY --from=build-server /server /app
COPY --from=build-server /usr /usr
COPY --from=build-client /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=build-client /client/client /app/client

ENV REDASH_VERSION=v8.0.0 \
    REDASH_HOST= \
    REDASH_CSV_WRITER_ENCODING=utf-8 \
    REDASH_WEB_WORKERS=1 \
    WORKERS_COUNT=1 \
    REDASH_ALLOW_SCRIPTS_IN_USER_INPUT=true \
    QUEUES=queries,scheduled_queries,celery \
    REDASH_LOG_LEVEL=INFO \
    PYTHONUNBUFFERED=0

WORKDIR /app
EXPOSE 5000

RUN adduser --system --group redash \
    && chown -R redash /app

USER redash

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["help"]
