#!/bin/bash

timeout=$(( $( date +%s ) + "${PING_TIMEOUT}" ))
ret=1

if [ "${DB_TYPE}" == "mysql" ]; then
  if [ "${DB_PASS}" == "" ]; then
    until [ "${ret}" -eq 0 ] || [[ $( date +%s ) -gt "${timeout}" ]]; do
       mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" "${DB_DATABASE}" -e 'SELECT 1;'
       ret="$?"
       sleep 3
    done
  else
    until [ "${ret}" -eq 0 ] || [[ $( date +%s ) -gt "${timeout}" ]]; do
       mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_DATABASE}" -e 'SELECT 1;'
       ret="$?"
       sleep 3
    done
  fi
fi

if [ "${DB_TYPE}" == "postgresql" ]; then
  if [ "${DB_PASS}" != "" ]; then
    export PGPASSWORD="${DB_PASS}"
  fi
  until [ "${ret}" -eq 0 ] || [[ $( date +%s ) -gt "${timeout}" ]]; do
      psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_DATABASE}" -c 'SELECT 1;'
      ret="$?"
      sleep 3
  done
fi

exit "${ret}"
