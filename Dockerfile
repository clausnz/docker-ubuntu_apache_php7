FROM ubuntu:16.04
LABEL author="Claus Bayer" email="claus.bayer@gmail.com"

VOLUME ["/var/www/html", "/var/log/apache2"]

RUN apt-get update -y && apt-get install -y software-properties-common \
    && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php \
    && apt-get update -y \
    && apt-get install -y \
    vim \
    dnsutils \
    net-tools \
    apache2 \
    php7.1 \
    php7.1-xmlrpc \
    php7.1-bz2 \
    php7.1-cgi \
    php7.1-cli \
    php7.1-dba \
    php7.1-dev \
    php7.1-fpm \
    php7.1-gd \
    php7.1-gmp \
    php7.1-opcache \
    php7.1-pspell \
    php7.1-recode \
    php7.1-common \
    php7.1-bcmath \
    php7.1-sqlite3 \
    php7.1-tidy \
    php7.1-json \
    php7.1-mbstring \
    php7.1-readline \
    php7.1-xml \
    php7.1-xsl \
    php7.1-curl \
    php7.1-zip \
    php7.1-ldap \
    php7.1-pgsql \
    php7.1-mcrypt \
    php7.1-imap \
    libphp7.1-embed \
    php7.1-intl \
    php7.1-enchant \
    php7.1-odbc \
    php7.1-snmp \
    php7.1-soap \
    php7.1-sybase \
    php7.1-phpdbg \
    libapache2-mod-php7.1 \
    php7.1-mysql \
    php7.1-interbase \
    php-xdebug

# configure Apache and create certificate
COPY apache.conf /etc/apache2/sites-enabled/000-default.conf
COPY apache-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
COPY ssl-params.conf /etc/apache2/conf-available/ssl-params.conf
RUN openssl \
    req -x509 \
    -nodes \
    -days 3650 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=GB/ST=London/L=London/O=IT Business/OU=IT Department/CN=localhost" \
    && openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 \
    && a2enmod rewrite ssl headers expires \
    && a2enconf ssl-params \
    # Apache log output to standard docker log /proc/self/fd/{1/2}
    && sed -i "s|ErrorLog.*|CustomLog /proc/self/fd/1 common\\nErrorLog /proc/self/fd/2|g" "/etc/apache2/apache2.conf" \
    && chown -R www-data:www-data /var/www

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# xdebug
COPY xdebug.ini /xdebug.ini

EXPOSE 80 443
CMD ["/usr/sbin/apachectl", "-D FOREGROUND"]