FROM ubuntu:16.04
LABEL author="Claus Bayer" email="claus.bayer@gmail.com"

VOLUME ["/var/www/html"]

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

RUN a2enmod rewrite

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# xdebug
COPY xdebug.ini /etc/php/7.1/cli/conf.d/xdebug.ini
COPY xdebug.ini /etc/php/7.1/apache2/conf.d/xdebug.ini

EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D FOREGROUND"]