# Redash v4.0
# docker run --rm -p 5000:5000 supinf/redash:4.0
# docker run --rm -p 5000:5000 -e REDASH_MAIL_SERVER=email-smtp.us-east-1.amazonaws.com -e REDASH_MAIL_PORT=465 -e REDASH_MAIL_USE_TLS=true -e REDASH_MAIL_USERNAME=foo -e REDASH_MAIL_PASSWORD=bar -e REDASH_MAIL_DEFAULT_SENDER=no-reply@example.com supinf/redash:4.0

FROM ubuntu:xenial-20180808

ENV REDASH_VERSION=v4.0.1

WORKDIR /app
EXPOSE 5000

# git clone Redash v4.0
RUN apt-get update \
    && apt-get install -y git \
    && git clone --depth=1 -b ${REDASH_VERSION} https://github.com/getredash/redash.git /app \
    && rm -rf tests old_migrations setup ./*.md ./*.yml ./.* 2>/dev/null | true \
    && apt-get remove --purge -y git && apt autoremove -y \
    && rm -rf /var/cache

# Solve server dependencies
# @see https://github.com/getredash/docker/blob/master/base/Dockerfile
RUN mkdir -p /var/cache/apt \
    && apt-get install -y python python-pip libmysqlclient-dev libsasl2-dev \
    && pip install -r requirements.txt -r requirements_all_ds.txt \
    && pip install -U setuptools==23.1.0 \
    && apt-get remove --purge -y python-pip libmysqlclient-dev libsasl2-dev \
    && apt autoremove -y \
    && rm -rf /var/cache /root/.cache

# Solve client dependencies
RUN mkdir -p /var/cache/apt \
    && apt-get install -y curl \
    && curl --silent --show-error https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs git \
    && npm install && npm run build \
    && apt-get remove --purge -y nodejs git curl \
    && apt autoremove -y \
    && rm -rf node_modules /var/cache /root/.npm /tmp/*

RUN adduser --system --group redash \
    && chown -R redash /app

ENV REDASH_HOST= \
    REDASH_CSV_WRITER_ENCODING=utf-8 \
    REDASH_WEB_WORKERS=1 \
    WORKERS_COUNT=1 \
    REDASH_ALLOW_SCRIPTS_IN_USER_INPUT=true \
    QUEUES=queries,scheduled_queries,celery \
    REDASH_LOG_LEVEL=INFO \
    PYTHONUNBUFFERED=0 \
    REDASH_DATABASE_URL=postgresql://postgres@localhost:5432/postgres \
    REDASH_REDIS_URL=redis://localhost:6379/0 \
    S6_VERSION=v1.21.4.0 \
    S6_LOGGING=1

# Install s6-overlay for running multiple processes in a container
RUN mkdir -p /var/cache/apt \
    && apt-get install -y gnupg2 curl \
    && s6_dl=https://github.com/just-containers/s6-overlay/releases/download \
    && s6_tar=s6-overlay-amd64.tar.gz \
    && curl --location --silent --show-error -O "${s6_dl}/${S6_VERSION}/${s6_tar}" \
    && curl --location --silent --show-error -O "${s6_dl}/${S6_VERSION}/${s6_tar}.sig" \
    && curl --location --silent --show-error https://keybase.io/justcontainers/key.asc | gpg --import \
    && gpg --verify ${s6_tar}.sig ${s6_tar} \
    && tar xzf ${s6_tar} -C / \
    && apt-get remove --purge -y gnupg2 curl \
    && apt autoremove -y \
    && rm -rf ${s6_tar} ${s6_tar}.sig /var/cache

# Install PostgreSQL v9.5
RUN mkdir -p /var/cache/apt \
    && apt-get install -y postgresql postgresql-contrib \
    && echo "host  all  postgres  0.0.0.0/0  trust" > /etc/postgresql/9.5/main/pg_hba.conf \
    && echo "host  all  redash    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf \
    && echo "stats_temp_directory='/tmp'" >> /etc/postgresql/9.5/main/postgresql.conf \
    && rm -rf /var/cache

# Install Redis v4.0
RUN mkdir -p /var/cache/apt \
    && apt-get install -y build-essential curl tcl \
    && cd /tmp \
    && curl --location --silent --show-error -O http://download.redis.io/redis-stable.tar.gz \
    && tar xzf redis-stable.tar.gz \
    && cd redis-stable \
    && make && make install \
    && mkdir /etc/redis \
    && cp /tmp/redis-stable/redis.conf /etc/redis \
    && adduser --system --group --no-create-home redis \
    && mkdir -p /var/lib/redis \
    && chown redis:redis /var/lib/redis \
    && chmod 770 /var/lib/redis \
    && apt-get remove --purge -y build-essential curl tcl \
    && apt autoremove -y \
    && cd / \
    && rm -rf /var/cache /tmp/*

# Configure user services with /etc/services.d/
RUN mkdir -p /etc/services.d/postgres \
    && echo "#!/usr/bin/with-contenv sh\n\
s6-setuidgid postgres /usr/lib/postgresql/9.5/bin/postgres \
-D /var/lib/postgresql/9.5/main \
-c config_file=/etc/postgresql/9.5/main/postgresql.conf" \
      > /etc/services.d/postgres/run

RUN mkdir -p /etc/services.d/redis \
    && echo "#!/usr/bin/with-contenv sh\n\
/usr/local/bin/redis-server /etc/redis/redis.conf" \
      > /etc/services.d/redis/run

RUN mkdir -p /etc/services.d/celery-worker \
    && echo "#!/usr/bin/with-contenv sh\n\
sleep 3\n\
cd /app\n\
s6-setuidgid postgres /app/bin/docker-entrypoint create_db\n\
s6-setuidgid redash /app/bin/docker-entrypoint scheduler" \
      > /etc/services.d/celery-worker/run

ENTRYPOINT ["/init"]
CMD ["s6-setuidgid", "redash", "/app/bin/docker-entrypoint", "server"]
