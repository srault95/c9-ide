#!/bin/bash

set -e

/scripts/gen-ssl.sh || exit 1

mkdir -vp /data/db

exec supervisord --nodaemon -c /etc/supervisor/supervisord.conf

