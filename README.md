# Docker Ubuntu / Apache / PHP7

Docker container with installed Ubuntu, Apache and PHP7.

## About

#### Installed Software:

- Ubuntu 16.04
- Apache 2
- PHP 7.1

#### Build image:

    docker build -t ubuntu-apache-php7 .

#### Example:

##### Run image with following command:

    docker run \
    -d \
    --restart=always \
    --name my_ubuntu-apache-php7 \
    -p 8000:80 \
    -v $(pwd):/var/www/ \
    clausnz/ubuntu-apache-php7:latest

##### Docker `docker-compose.yml` section:

    version: "3"
    services:
    web:
        image: "clausnz/ubuntu-apache-php71:latest"
        restart: "always"
        ports:
        - "8000:80"
        volumes:
        - .:/var/www/

