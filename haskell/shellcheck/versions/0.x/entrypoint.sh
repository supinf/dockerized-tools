#!/bin/sh

rc=0

if [ "x${IGNORE_PATH}" = "x" ]; then
  for file in $( find . -type f -name "*.sh" -print | sed 's/^\.\///' ); do
    shellcheck -f tty "$file" || rc=$?
  done
else
  for file in $( find . -type f -name "*.sh" -print | sed 's/^\.\///' | grep -v "${IGNORE_PATH}" ); do
    shellcheck -f tty "$file" || rc=$?
  done
fi

exit $rc
