#!/bin/bash

exec supervisord --nodaemon -c /etc/supervisor/supervisord.conf

