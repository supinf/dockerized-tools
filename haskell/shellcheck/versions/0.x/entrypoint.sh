#!/bin/sh

rc=0
for file in $( find . -type f -name "*.sh" -print | sed 's/^\.\///' ); do
  shellcheck -f tty "$file" || rc=$?
done
exit $rc
