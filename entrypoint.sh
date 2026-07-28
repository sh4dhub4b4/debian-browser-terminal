#!/bin/bash

set -e

echo "AUTH_USER=$AUTH_USER"

if [ -z "$AUTH_USER" ] || [ -z "$AUTH_PASSWORD" ]; then
    echo "Missing authentication variables"
    exit 1
fi


htpasswd -bc \
    /etc/nginx/.htpasswd \
    "$AUTH_USER" \
    "$AUTH_PASSWORD"


echo "Generated password file:"
cat /etc/nginx/.htpasswd


envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf


echo "Starting supervisor..."

exec supervisord -n
