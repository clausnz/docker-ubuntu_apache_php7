# Docker image: ubuntu_apache_php7

Run image with following command:

    docker run \
        -d \
        --restart=always \
        --name my_ubuntu-apache-php7 \
        -p 8000:80 \
        -v "$PWD":/var/www/ \
        --link my_container_to_link: \
    ubuntu-apache-php7


Build image:

    docker build -t ubuntu-apache-php7 .