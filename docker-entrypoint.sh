#!/bin/bash
set -i

APACHE_XDEBUG_PATH="/etc/php/7.1/apache2/conf.d/xdebug.ini"
CLI_XDEBUG_PATH="/etc/php/7.1/cli/conf.d/xdebug.ini"
VIRTUAL_HOST_FILE="/etc/apache2/sites-enabled/000-default.conf"
VIRTUAL_HOST_FILE_SSL="/etc/apache2/sites-enabled/default-ssl.conf"

MAC_HOST="$(dig +short docker.for.mac.host.internal)"
WINDOWS_HOST="$(dig +short docker.for.win.host.internal)"
LINUX_HOST="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')"

# Set remote host ip from docker var. Works best on Mac or Windows. Linux may not work correctly.
XDEBUG_REMOTE_HOST=$([ ! -z "$MAC_HOST" ] && echo "$MAC_HOST" || [ ! -z "$WINDOWS_HOST" ] && echo "$WINDOWS_HOST" || echo "$LINUX_HOST")

# Set remote host
sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" ${APACHE_XDEBUG_PATH}
sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" ${CLI_XDEBUG_PATH}

# Set xdebug port if given as env
if [ -n "${XDEBUG_REMOTE_PORT}" ]; then
    sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" ${APACHE_XDEBUG_PATH}
    sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" ${CLI_XDEBUG_PATH}
fi

# Set document root if given as env
if [ -n "${DOCUMENT_ROOT}" ]; then
    # http
    sed -i "s|DocumentRoot.*|DocumentRoot /var/www/html${DOCUMENT_ROOT}|g" ${VIRTUAL_HOST_FILE}
    sed -i "s|<Directory.*|<Directory /var/www/html${DOCUMENT_ROOT}/>|g" ${VIRTUAL_HOST_FILE}
    # https
    sed -i "s|DocumentRoot.*|DocumentRoot /var/www/html${DOCUMENT_ROOT}|g" ${VIRTUAL_HOST_FILE_SSL}
    sed -i "s|<Directory.*|<Directory /var/www/html${DOCUMENT_ROOT}/>|g" ${VIRTUAL_HOST_FILE_SSL}
fi

exec "$@"
