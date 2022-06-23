FROM php:7.4-cli AS BUILD

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd xdebug

FROM php:7.4-apache as BUILD1

COPY --from=BUILD /usr/local/bin/install-php-extensions /usr/local/bin/

RUN  pecl install xdebug-2.8.1 \
    && docker-php-ext-enable xdebug

#RUN apt-get update && \
#  apt-get install  -y vim git unzip socat yum yum-utils && \
#   apt-get install -y autoconf automake libtool
#RUN install-php-extensions pdo_pgsql pgsql ldap gd zip imap 

RUN install-php-extensions ldap gd zip imap pdo pdo_mysql

FROM BUILD1 AS Builder
COPY ./php.ini "$PHP_INI_DIR/php.ini"

ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_DOCUMENT_ROOT /var/www/limesurvey
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV PORT 8000

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's/Listen 80/Listen 8000/g' /etc/apache2/ports.conf
RUN sed -ri -e 's/:80/:8000/g' /etc/apache2/sites-enabled/*

COPY dev.default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod 776 /etc/apache2/sites-available/000-default.conf

RUN echo "Include sites-enabled/*.conf" >> /etc/apache2/apache2.conf
RUN echo "DocumentRoot /var/www/limesurvey" >> /etc/apache2/apache2.conf
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
COPY start-apache /usr/local/bin
RUN chmod 776 /usr/local/bin/start-apache

COPY ports.conf /etc/apache2/ports.conf
RUN chmod 776 /etc/apache2/ports.conf

COPY ./envvars /etc/apache2/envvars
RUN chmod +rwx /etc/apache2/envvars

#RUN a2enmod env
RUN a2enmod rewrite
#RUN a2enmod cgi
#RUN a2ensite 000-default.conf

#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
#RUN cat /etc/apache2/sites-enabled/000-default.conf

#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
#RUN cat /etc/apache2/sites-available/000-default.conf

RUN chmod +x /usr/local/bin/docker-php-entrypoint
RUN mkdir -p /var/www/limesurvey
COPY src/limesurvey/ /var/www/limesurvey
RUN ls -lta /var/www/limesurvey

RUN chown -R $UID:$GID  /var/www/limesurvey
#RUN chown -R www-data:www-data /var/www/limesurvey
RUN mkdir -p /var/www/limesurvey/tmp/runtime
RUN chmod -R 777 /var/www/limesurvey/tmp/runtime
RUN mkdir -p /var/www/limesurvey/tmp/assets
RUN chmod -R 777 /var/www/limesurvey/tmp/assets
RUN mkdir -p /var/www/limesurvey/tmp/sessions
RUN chmod -R 777 /var/www/limesurvey/tmp/sessions

RUN /bin/bash -c "source /etc/apache2/envvars"
RUN service apache2 start

EXPOSE 8000 80
WORKDIR /var/www/limesurvey
CMD ["start-apache"]