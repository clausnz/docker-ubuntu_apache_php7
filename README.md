# Docker image: ubuntu_apache_php7

- Ubuntu 16.04
- Apache 2
- PHP 7.0

Build image:

    docker build -t ubuntu-apache-php7 .

Run image with following command:

    docker run \
        -d \
        --restart=always \
        --name my_ubuntu-apache-php7 \
        -p 8000:80 \
        -v "$PWD":/var/www/ \
        --link my_container_to_link: \
    ubuntu-apache-php7

Docker `docker-compose.yml` section:

    version: "3"
    services:
    web:
        image: "clausnz/ubuntu-apache-php7:v1"
        restart: "always"
        ports:
        - "8000:80"
        volumes:
        - .:/var/www/

