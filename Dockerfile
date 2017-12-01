FROM ubuntu:16.04
LABEL author="Claus Bayer" email="claus.bayer@gmail.com"

VOLUME ["/var/www"]

ENV APACHE_CONF="apache.conf"

RUN apt-get update && apt-get install -y \
    #   Apache
    apache2 \
    #   PHP 7.0
    php7.0 \
    php7.0-xmlrpc \
    php7.0-bz2 \
    php7.0-cgi \
    php7.0-cli \
    php7.0-dba \
    php7.0-dev \
    php7.0-fpm \
    php7.0-gd \
    php7.0-gmp \
    php7.0-opcache \
    php7.0-pspell \
    php7.0-recode \
    php7.0-common \
    php7.0-bcmath \
    php7.0-sqlite3 \
    php7.0-tidy \
    php7.0-json \
    php7.0-mbstring \
    php7.0-readline \
    php7.0-xml \
    php7.0-xsl \
    php7.0-curl \
    php7.0-zip \
    php7.0-ldap \
    php7.0-pgsql \
    php7.0-mcrypt \
    php7.0-imap \
    libphp7.0-embed \
    php7.0-intl \
    php7.0-enchant \
    php7.0-odbc \
    php7.0-snmp \
    php7.0-soap \
    php7.0-sybase \
    php7.0-phpdbg \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-interbase \
    php-xdebug \
    #   Tools
    vim

#   Setup Apache
COPY ${APACHE_CONF} /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN service apache2 start

EXPOSE 80 5432
CMD ["/usr/sbin/apachectl", "-D FOREGROUND"]