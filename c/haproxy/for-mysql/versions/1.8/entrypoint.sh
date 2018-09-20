#!/bin/sh

if [ -z "${MYSQL_ENDPOINT}" ]; then
  echo 'MYSQL_ENDPOINT must be specified as an environment variable.' 1>&2
  exit 1
fi

cat << EOF > haproxy.cfg
defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

listen mysql
    bind 0.0.0.0:3306
    mode tcp
    balance roundrobin
    server mysql1 ${MYSQL_ENDPOINT}
EOF

exec /docker-entrypoint.sh haproxy -f haproxy.cfg
