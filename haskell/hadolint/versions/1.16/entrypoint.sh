#!/bin/sh

rc=0

if [ "x${IGNORE_PATH}" = "x" ]; then
  for file in $( find . -type f -name "${DOCKERFILE_NAME}" -print | sed 's/^\.\///' ); do
    echo -e "\n@ ${file}"
    hadolint "$@" "${file}" || rc=$?
  done
else
  for file in $( find . -type f -name "${DOCKERFILE_NAME}" -print | sed 's/^\.\///' | grep -v "${IGNORE_PATH}" ); do
    echo -e "\n@ ${file}"
    hadolint "$@" "${file}" || rc=$?
  done
fi

exit $rc
