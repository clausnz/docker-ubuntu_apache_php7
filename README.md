# Docker Ubuntu / Apache / PHP

Docker container with installed and configured Ubuntu, Apache, PHP7 and XDebug.

## About

#### Installed Software:

- `Ubuntu 16.04`
- `Apache 2`
- `PHP 7.1`
- `Xdebug v2.5.5`

# Table of Contents

* [Volumes and Environment Variables](#volumes-and-environment-variables)
* [Build Image](#build-image)
* [Run Container](#run-container)
* [Docker-Compose Section](#docker-compose-section)
* [Setup PHPStorm for XDebug with Docker](#setup-phpstorm-for-xdebug-with-docker)


## Volumes and Environment Variables

#### Volumes

* `/var/www/html`

#### Environment Variables

The environment variables can be changed with the `-e` parameter 

* `XDEBUG_REMOTE_HOST` - When using Mac or Windows as host, this variable is set automatically
* `XDEBUG_REMOTE_PORT` - Default 9000

## Build Image

    git clone https://github.com/clausnz/docker_ubuntu-apache-php.git
    cd docker_ubuntu-apache-php
    docker build -t <tag_name> .

## Run Container

##### Run image with following command:

    docker run \
        -d \
        --restart=always \
        --name my_ubuntu-apache-php \
        -p 8000:80 \
        -v $(pwd):/var/www/html/ \
        clausnz/ubuntu-apache-php:latest

## Docker-Compose Section

Edit `docker-compose.yml`

```
version: "3"

services:
    web:
        image: "clausnz/ubuntu-apache-php:latest"
        restart: "always"
        ports:
            - "8000:80"
        volumes:
            - .:/var/www/html
```

## Example configuration with MySQL and Adminer

```
version: "3"

# create following directories in project root:
# ./mysql_datadir

services:
    web:
        image: "clausnz/ubuntu-apache-php:latest"
        restart: "always"
        ports:
            - "8000:80"
        volumes:
            - .:/var/www/html
    db:
        image: mysql
        restart: always
        volumes:
            - ./mysql_datadir:/var/lib/mysql
        ports:
            - "3306:3306"
        environment:
            MYSQL_ROOT_PASSWORD: example
            MYSQL_DATABASE: example
            MYSQL_USER: example
            MYSQL_PASSWORD: example

    adminer:
        image: adminer
        restart: always
        ports:
            - 8080:8080
        environment:
          - "ADMINER_DESIGN=lucas-sandery"
```
        
## Setup PHPStorm for XDebug with Docker

As the image is preconfigured with XDebug for Docker debugging, you only have to set up your IDE. Here is an example for PHPStorm:

#### Setup XDebug in PHPStorm > Settings > Languages & Frameworks > PHP > Debug
![Setup XDebug](docs/images/phpstorm-setup-xdebug.png)

#### Setup Server in PHPStorm > Settings > Languages & Frameworks > PHP > Servers
![Setup Server](docs/images/phpstorm-settings-server.png)

#### Setup Run/Debug Configuration
![Setup Run](docs/images/phpstorm-setup-run.png)

#### Set your breakpoints and you're done.