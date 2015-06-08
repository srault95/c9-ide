#!/bin/bash

chmod +x /usr/local/bin/gen-ssl.sh && /usr/local/bin/gen-ssl.sh

exec supervisord --nodaemon -c /etc/supervisor/supervisord.conf

