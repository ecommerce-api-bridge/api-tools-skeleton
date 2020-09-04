FROM composer as composer
WORKDIR /app

ARG API_MODULE_REPO_URL
ARG API_MODULE_VERSION

COPY . .
RUN rm -rf vendor \
           public/vendor/ \
           config/development.config.php \
           config/autoload/local.php \
           config/autoload/*.local.php \
           data/cache/* \
           .git \
           composer.lock \
           nbproject \
           .idea \
           .dockerfile \
           .env \
           .gitignore \
           ._* \
           .~lock.* \
           .buildpath \
           .DS_Store \
           .idea \
           .project \
           .settings \
           Dockerfile \
           docker-compose.yml \
           Vargantfile \
           phpcs.xml \
           phpunit.xml.dist

COPY config/autoload/local.php.dist config/autoload/local.php

RUN composer config repositories.repo-name vcs ${API_MODULE_REPO_URL} \
    && composer install --no-dev --prefer-dist --optimize-autoloader \
    && composer require --update-no-dev --no-interaction ${API_MODULE_VERSION} \
    && composer development-disable

FROM php:7.4-apache

RUN apt-get update \
 && apt-get install -y git zlib1g-dev libxml2-dev zip unzip libpq-dev \
 && apt-get clean -y \
 && docker-php-ext-install soap pdo_pgsql \
 && a2enmod rewrite \
 && sed -i 's!/var/www/html!/var/www/public!g' /etc/apache2/sites-available/000-default.conf \
 && mv /var/www/html /var/www/public \
 && echo "AllowEncodedSlashes On" >> /etc/apache2/apache2.conf

WORKDIR /var/www
COPY --from=composer --chown=www-data /app .
