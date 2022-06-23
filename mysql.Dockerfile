FROM mysql:latest

ENV   MYSQL_ROOT_PASSWORD limesurvey 
ENV   MYSQL_RUN_DIR /run/mysqld 
ENV   MYSQL_LOG_DIR /var/log/mysql

COPY ./sqlscripts/init.sql /docker-entrypoint-initdb.d/init.sql

ENV   MYSQL_DATA_DIR /var/lib/mysql 
RUN    printenv
EXPOSE 3306 33060 33061
CMD ["mysqld"]