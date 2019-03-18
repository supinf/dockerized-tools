#!/bin/sh

cd /code || exit 1
exec node check_api "$1"
