#!/bin/bash

set -e


if [ -z "$AUTH_USER" ] || [ -z "$AUTH_PASSWORD" ]; then
    echo "Missing authentication variables"
    exit 1
fi


htpasswd -bc \
    /etc/nginx/.htpasswd \
    "$AUTH_USER" \
    "$AUTH_PASSWORD"


envsubst \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf


exec supervisord -n
