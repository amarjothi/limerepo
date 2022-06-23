FROM php:7.4-cli AS builder

ADD "https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions" /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd xdebug

FROM php:7.4-apache as builder1

COPY --from=builder /usr/local/bin/install-php-extensions /usr/local/bin/

RUN  pecl install xdebug-2.8.1 \
    && docker-php-ext-enable xdebug


FROM builder1 
RUN install-php-extensions ldap gd zip imap pdo pdo_mysql

#RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
#COPY ./php.ini-production "$PHP_INI_DIR/php.ini"
COPY ./php.ini "$PHP_INI_DIR/php.ini"
# ensure www-data user exists
RUN set -x ; \
  addgroup --gid 33 www-data ; \
  adduser --uid 33 --gid 82 www-data www-data && exit 0 ; exit 1

ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_DOCUMENT_ROOT /var/www/limesurvey/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV PORT 8000
RUN usermod -G root www-data
RUN chmod -R u=rwx,g=rwx,o+rx /etc/apache2/
RUN chmod -R u=rwx,g=rwx,o+rx /var/log/apache2/

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod u=rwx,g=rwx,o+rx /etc/apache2/sites-available/000-default.conf
COPY start-apache /usr/local/bin
RUN chmod u=rwx,g=rwx,o+rx /usr/local/bin/start-apache
RUN a2enmod rewrite

RUN mkdir -p /var/www/limesurvey
COPY src/limesurvey/ /var/www/limesurvey
RUN ls -lta /var/www/limesurvey