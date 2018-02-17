#!/bin/bash
set -i

########################
### Script variables ###
########################

APACHE_XDEBUG_PATH="/etc/php/7.1/apache2/conf.d/xdebug.ini"
CLI_XDEBUG_PATH="/etc/php/7.1/cli/conf.d/xdebug.ini"

VIRTUAL_HOST_FILE="/etc/apache2/sites-enabled/000-default.conf"
VIRTUAL_HOST_FILE_SSL="/etc/apache2/sites-enabled/default-ssl.conf"

APACHE_LOG_DIR="/var/log/apache2"
PHP_INI_APACHE="/etc/php/7.1/apache2/php.ini"
PHP_INI_CLI="/etc/php/7.1/cli/php.ini"



########################
### Script functions ###
########################

function log_to_file() {
    declare -a virtual_host_file=("$VIRTUAL_HOST_FILE" "$VIRTUAL_HOST_FILE_SSL") # http/https
    for file in "${virtual_host_file[@]}"
    do
    sed -i \
           -e "s|#.*<access_log_placeholder>|CustomLog ${APACHE_LOG_DIR}/access.log combined|g" \
           -e "s|#.*<error_log_placeholder>|ErrorLog ${APACHE_LOG_DIR}/error.log|g" \
           "$file"
    done
}

function set_date_timezone() {
    declare -a ini_path=("${PHP_INI_APACHE}" "${PHP_INI_CLI}")
    for path in "${ini_path[@]}"
    do
        sed -i "s|;date.timezone.*|date.timezone = ${DATE_TIMEZONE}|g" "$path"
    done
}

function set_document_root() {
    declare -a virtual_host_file=("$VIRTUAL_HOST_FILE" "$VIRTUAL_HOST_FILE_SSL") # http/https
    for file in "${virtual_host_file[@]}"
    do
        sed -i \
              -e "s|DocumentRoot.*|DocumentRoot /var/www/html${DOCUMENT_ROOT}|g" \
              -e "s|<Directory.*|<Directory /var/www/html${DOCUMENT_ROOT}/>|g" \
              "$file"
    done
}

function set_xdebug_remote_host() {
    # declare vars
    MAC_HOST="$(dig +short docker.for.mac.host.internal)"
    WINDOWS_HOST="$(dig +short docker.for.win.host.internal)"
    LINUX_HOST="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')"

    # Set xdebug remote host ip from docker var. Works best on Mac or Windows. May not work correctly for other OS
    XDEBUG_REMOTE_HOST=$([ ! -z "$MAC_HOST" ] && echo "$MAC_HOST" || [ ! -z "$WINDOWS_HOST" ] && echo "$WINDOWS_HOST" || echo "$LINUX_HOST")

    # Set xdebug remote host
    \sed -i "s/xdebug\.remote_host.*/xdebug\.remote_host = ${XDEBUG_REMOTE_HOST//./\\.}/g" /xdebug.ini
}

function set_xdebug_port() {
    \sed -i "s/xdebug\.remote_port.*/xdebug\.remote_port = ${XDEBUG_REMOTE_PORT}/g" /xdebug.ini
}



################################################
### Production and Development mode settings ###
################################################

# Set document root if given as env
if [ -n "${DOCUMENT_ROOT}" ]; then set_document_root; fi

# Set data.timezone in php.ini if given as env
if [ -n "${DATE_TIMEZONE}" ]; then set_date_timezone; fi

# if APP_ENV is not set, run in development mode
if [ -z "${APP_ENV}" ]; then APP_ENV="development"; fi



#################################
### Development mode settings ###
#################################

if [ -n "${APP_ENV}" ] && [ "${APP_ENV}" == "development" ]; then

    # copy debug configuration
    # TODO: create symbolic links if possible
    \ln -sf /xdebug.ini "$APACHE_XDEBUG_PATH" && \ln -sf /xdebug.ini "$CLI_XDEBUG_PATH"

    # set xdebug remote host
    set_xdebug_remote_host

    # Set xdebug port if given as env
    if [ -n "$XDEBUG_REMOTE_PORT" ]; then set_xdebug_port; fi

    # Set log to file if given as env
    if [ -n "$LOG_TO_FILE" ] && [ "$LOG_TO_FILE" -eq 1 ]; then log_to_file; fi

    # enable xdebug
    \phpenmod xdebug
fi



################################
### Production mode settings ###
################################

if [ -n "$APP_ENV" ] && [ "$APP_ENV" == "production" ]; then
    # set log to file
    log_to_file

    # remove possible xdebug conf
    \rm -f "$APACHE_XDEBUG_PATH" "$CLI_XDEBUG_PATH"

    # disable xdebug
    \phpdismod xdebug
fi

exec "$@"
