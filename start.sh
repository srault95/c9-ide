#!/bin/bash

chmod +x /usr/local/bin/gen-ssl.sh || exit 1

/usr/local/bin/gen-ssl.sh || exit 1

mkdir -vp /data/db

exec supervisord --nodaemon -c /etc/supervisor/supervisord.conf

