#!/bin/bash
set -i

APACHE_XDEBUG_PATH="/etc/php/7.1/apache2/conf.d/xdebug.ini"
CLI_XDEBUG_PATH="/etc/php/7.1/cli/conf.d/xdebug.ini"

VIRTUAL_HOST_FILE="/etc/apache2/sites-enabled/000-default.conf"
VIRTUAL_HOST_FILE_SSL="/etc/apache2/sites-enabled/default-ssl.conf"

MAC_HOST="$(dig +short docker.for.mac.host.internal)"
WINDOWS_HOST="$(dig +short docker.for.win.host.internal)"
LINUX_HOST="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')"

APACHE_LOG_DIR="/var/log/apache2"
PHP_INI_APACHE="/etc/php/7.1/apache2/php.ini"
PHP_INI_CLI="/etc/php/7.1/cli/php.ini"



# Set remote host ip from docker var. Works best on Mac or Windows. May not work correctly for other OS
XDEBUG_REMOTE_HOST=$([ ! -z "$MAC_HOST" ] && echo "$MAC_HOST" || [ ! -z "$WINDOWS_HOST" ] && echo "$WINDOWS_HOST" || echo "$LINUX_HOST")

# Set remote host
declare -a xdebug_path=("${APACHE_XDEBUG_PATH}" "${CLI_XDEBUG_PATH}")
for path in "${xdebug_path[@]}"
do
    sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" ${path}
done


# Set xdebug port if given as env
if [ -n "${XDEBUG_REMOTE_PORT}" ]; then
    declare -a xdebug_path=("${APACHE_XDEBUG_PATH}" "${CLI_XDEBUG_PATH}")
    for path in "${xdebug_path[@]}"
    do
        sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" ${path}
    done
fi

# Set document root if given as env
if [ -n "${DOCUMENT_ROOT}" ]; then
    declare -a virtual_host_file=("${VIRTUAL_HOST_FILE}" "${VIRTUAL_HOST_FILE_SSL}") # http/https
    for file in "${virtual_host_file[@]}"
    do
        sed -i \
              -e "s|DocumentRoot.*|DocumentRoot /var/www/html${DOCUMENT_ROOT}|g" \
              -e "s|<Directory.*|<Directory /var/www/html${DOCUMENT_ROOT}/>|g" \
              ${file}
    done
fi

# Set log to file if given as env
if [ -n "${LOG_TO_FILE}" ] && [ "${LOG_TO_FILE}" -eq 1 ]; then
    declare -a virtual_host_file=("${VIRTUAL_HOST_FILE}" "${VIRTUAL_HOST_FILE_SSL}") # http/https
    for file in "${virtual_host_file[@]}"
    do
    sed -i \
           -e "s|#.*<access_log_placeholder>|CustomLog ${APACHE_LOG_DIR}/access.log combined|g" \
           -e "s|#.*<error_log_placeholder>|ErrorLog ${APACHE_LOG_DIR}/error.log|g" \
           ${file}
    done
fi

# Set data.timezone in php.ini if given as env
if [ -n "${DATE_TIMEZONE}" ]; then
    declare -a ini_path=("${PHP_INI_APACHE}" "${PHP_INI_CLI}")
    for path in "${ini_path[@]}"
    do
        sed -i "s|;date.timezone.*|date.timezone = ${DATE_TIMEZONE}|g" ${path}
    done
fi

exec "$@"
