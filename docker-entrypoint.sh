#!/bin/bash
set -i

APACHE_XDEBUG_PATH="/etc/php/7.1/apache2/conf.d/xdebug.ini"
CLI_XDEBUG_PATH="/etc/php/7.1/cli/conf.d/xdebug.ini"

# Set remote host ip from docker var. Only works on Mac or Windows
if [ -n "$(dig +short docker.for.mac.host.internal)" ]; then
    XDEBUG_REMOTE_HOST="$(dig +short docker.for.mac.host.internal)"
elif [ -n "$(dig +short docker.for.win.host.internal)" ]; then
    XDEBUG_REMOTE_HOST="$(dig +short docker.for.win.host.internal)"
fi

# If remote host is empty (not set or given as env), set it (may not work correctly for debugging)
if [ -z "${XDEBUG_REMOTE_HOST}" ]; then
    XDEBUG_REMOTE_HOST="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')"
fi

# Set remote host
sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" ${APACHE_XDEBUG_PATH}
sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" ${CLI_XDEBUG_PATH}

# Set xdebug port if given as env
if [ -n "${XDEBUG_REMOTE_PORT}" ]; then
    sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" ${APACHE_XDEBUG_PATH}
    sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" ${CLI_XDEBUG_PATH}
fi

exec "$@"
