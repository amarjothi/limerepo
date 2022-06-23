FROM php:7.4-cli AS builder

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd xdebug

FROM php:7.4-apache as builder1

COPY --from=builder /usr/local/bin/install-php-extensions /usr/local/bin/

RUN  pecl install xdebug-2.8.1 \
    && docker-php-ext-enable xdebug 

#RUN apt-get update && \
#  apt-get install  -y vim git unzip socat yum yum-utils && \
#   apt-get install -y autoconf automake libtool
#RUN install-php-extensions pdo_pgsql pgsql ldap gd zip imap 

RUN install-php-extensions ldap gd zip imap pdo pdo_mysql

FROM builder1 AS builder2
#RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
#COPY ./php.ini-production "$PHP_INI_DIR/php.ini"
COPY ./php.ini "$PHP_INI_DIR/php.ini"
# ensure www-data user exists
USER root

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN set -x ; \ 
    userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /var/www/limesurvey &&\
    chown --changes --silent --no-dereference --recursive \
          --from=33:33 ${USER_ID}:${GROUP_ID} \
        /var/run/apache2 \
        /var/log \
        /var/log/apache2 \
        /etc/apache2 \
        /var/run \
        /var/lock && exit 0 ; exit 1
        
RUN usermod -a -G root www-data
RUN usermod -a -G adm www-data

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_DOCUMENT_ROOT=/var/www/limesurvey/
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV PORT=8000
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_ENVVARS=/etc/apache2/envvars

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's/Listen 80/Listen 8000/g' /etc/apache2/ports.conf
RUN sed -ri -e 's/:80/:8000/g' /etc/apache2/sites-enabled/*

COPY prod.default.conf /etc/apache2/sites-available/000-default.conf
COPY prod.default-ssl.conf /etc/apache2/sites-available/prod.default-ssl.conf
RUN chmod 776 /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/prod.default-ssl.conf
RUN chmod -R 776 /etc/apache2/ /var/log/apache2/

#COPY apache2.conf /etc/apache2/apache2.conf
#RUN chmod 776 /etc/apache2/apache2.conf

RUN echo "Include sites-enabled/*.conf" >> /etc/apache2/apache2.conf
RUN echo "DocumentRoot /var/www/limesurvey" >> /etc/apache2/apache2.conf
RUN echo "ServerName thepollster" >> /etc/apache2/apache2.conf
COPY start-apache /usr/local/bin
RUN chmod 776 /usr/local/bin/start-apache

RUN mkdir -p /var/www/limesurvey
RUN mkdir /limesurvey
COPY src/limesurvey/ /limesurvey
RUN  cp -R /limesurvey /var/www/
RUN chown -R www-data:www-data /var/www/limesurvey

RUN find /var/www/limesurvey -type d -exec chmod g+rwx {} +
RUN find /var/www/limesurvey -type f -exec chmod g+rwx {} +
RUN find /var/www/limesurvey -type d -exec chmod u+rwx {} +
RUN find /var/www/limesurvey -type f -exec chmod u+rwx {} +
RUN find /var/www/limesurvey -type d -exec chmod o+rw {} +
RUN find /var/www/limesurvey -type f -exec chmod o+rw {} +

RUN mkdir -p /var/log/apache2 /var/run/apache2
RUN chmod -R o+rw /var/run /var/log /var/lock /var/log/apache2 /var/run/apache2
RUN chmod -R 776 /var/run 


RUN mkdir -p /var/www/limesurvey/tmp/runtime
RUN chmod -R 777 /var/www/limesurvey/tmp/runtime
RUN mkdir -p /var/www/limesurvey/tmp/assets
RUN chmod -R 777 /var/www/limesurvey/tmp/assets
RUN mkdir -p /var/www/limesurvey/tmp/sessions
RUN chmod -R 777 /var/www/limesurvey/tmp/sessions
RUN mkdir -p /var/www/limesurvey/upload
RUN chmod -R 777 /var/www/limesurvey/upload

COPY ./envvars /etc/apache2/envvars
RUN chmod 776 /etc/apache2/envvars
RUN /bin/bash -c "source /etc/apache2/envvars"

#RUN echo "127.0.0.1 thepollster" >> /etc/hosts
RUN echo "*               soft    nofile          8192" >> /etc/security/limits.conf
RUN echo "*               hard    nofile          8192" >> /etc/security/limits.conf
#RUN echo "35.176.63.145 thepollster" >> /etc/hosts

RUN a2enmod rewrite
EXPOSE 8000
WORKDIR /var/www/limesurvey

USER www-data
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]