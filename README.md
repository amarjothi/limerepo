# Build an image from the Dockerfile and assign it a name

$ docker build -t eg_postgresql .
Run the PostgreSQL server container (in the foreground):

$ docker run --rm -P --name pg_test eg_postgresql
There are two ways to connect to the PostgreSQL server. We can use Link Containers, or we can access it from our host (or the network).

Note: The --rm removes the container and its image when the container exits successfully.

Use container linking
Containers can be linked to another container’s ports directly using --link remote_name:local_alias in the client’s docker run. This sets a number of environment variables that can then be used to connect:

$ docker run --rm -t -i --link pg_test:pg eg_postgresql bash

[eg. psql -h localhost -p 32769 -d docker -U docker --password (docker)]

postgres@7ef98b1b7243:/$ psql -h $PG_PORT_5432_TCP_ADDR -p $PG_PORT_5432_TCP_PORT -d docker -U docker --password
Connect from your host system
Assuming you have the postgresql-client installed, you can use the host-mapped port to test as well. You need to use docker ps to find out what local host port the container is mapped to first:

$ docker ps

CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS                                      NAMES
5e24362f27f6        eg_postgresql:latest   /usr/lib/postgresql/   About an hour ago   Up About an hour    0.0.0.0:49153->5432/tcp                    pg_test

$ psql -h localhost -p 49153 -d docker -U docker --password
Test the database
Once you have authenticated and have a docker =# prompt, you can create a table and populate it.

psql (9.3.1)
Type "help" for help.

$ docker=# CREATE TABLE cities (
docker(#     name            varchar(80),
docker(#     location        point
docker(# );
CREATE TABLE
$ docker=# INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
INSERT 0 1
$ docker=# select * from cities;
     name      | location
---------------+-----------
 San Francisco | (-194,53)
(1 row)
Use the container volumes
You can use the defined volumes to inspect the PostgreSQL log files and to backup your configuration and data:

$ docker run --rm --volumes-from pg_test -t -i busybox sh

/ # ls
bin      etc      lib      linuxrc  mnt      proc     run      sys      usr
dev      home     lib64    media    opt      root     sbin     tmp      var
/ # ls /etc/postgresql/9.3/main/
environment      pg_hba.conf      postgresql.conf
pg_ctl.conf      pg_ident.conf    start.conf
/tmp # ls /var/log
ldconfig    postgresql

docker exec -it 77ccf2c /bin/sh
psql -h pg -p 5432 -U docker
SELECT datname FROM pg_database;

MYSQL

docker build -f Dockerfile . -t limeweb:latest
docker container run -d --name db -e MYSQL_RANDOM_ROOT_PASSWORD=password mysql
docker logs limesurveynew_db_1 2>&1 | grep GENERATED

docker exec -it limesurveynew_db_1 mysql  -uroot -p

docker-compose up --build

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';

show grants for 'limesurvey';
grant ALL PRIVILEGES ON *.* TO 'limesurvey';
show grants for 'limesurvey'
CREATE USER 'limesurvey'@'localhost' IDENTIFIED WITH mysql_native_password BY 'limesurvey';

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'limesurvey';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'limesurvey';
ALTER USER 'limesurvey'@'localhost' IDENTIFIED WITH mysql_native_password BY 'limesurvey';

AWS_PROFILE=amar docker push 702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster
AWS_PASSWORD=$(aws ecr get-login-password --region eu-west-2 --profile amar)
docker login -u AWS -p $(aws ecr get-login-password --region eu-west-2 --profile amar) 702193001748.dkr.ecr.eu-west-2.amazonaws.com

docker tag e9ae3c220b23 702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster
docker push 702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster

702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster:latest

export AWS_SECRET_ACCESS_KEY=AKIA2G7PW4UKET3OVJG5
export AWS_ACCESS_KEY_ID=/jeCtCJxHsbuBBmjbZECpikiyEQL1LBFKaAKJndf
export AWS_DEFAULT_REGION=eu-west-2
docker build -f prod.Dockerfile . -t limewebprod:latest
docker tag limewebprod:latest 702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster:latest

docker push 702193001748.dkr.ecr.eu-west-2.amazonaws.com/pollster:latest

aws ecs update-service --cluster POLLSTER-CLUSTER --service pollster --force-new-deployment --region eu-west-2


RUN /bin/bash -c 'getent passwd ${user} || \
    adduser --system --gid ${gid} ${docker_group} --uid ${uid} --shell /bin/bash ${user} || \
    usermod -l ${user} \$(getent passwd ${uid} | cut -d: -f1)'

RUN /bin/bash -c 'getent group docker && groupmod --gid ${docker_gid} docker \
        || groupadd --gid ${docker_gid} docker'
RUN /bin/bash -c 'groups ${user} | grep docker || usermod --groups ${docker_gid} ${user}'

/var/lib/docker/volumes
ssh -i "pollster.pem" root@ec2-3-8-215-123.eu-west-2.compute.amazonaws.com


pollster master password : l1m3surv3y

sg-d665d4be - default
mysql --host pollster.cw0ko9icjnut.eu-west-2.rds.amazonaws.com  --port 3306 --database pollster --user admin --password

mysql -h pollster.cw0ko9icjnut.eu-west-2.rds.amazonaws.com --ssl-ca=rds-ca-2019-root.pem --ssl-mode=VERIFY_IDENTITY -P 3306 -u admin -p

 Warning: Please enforce SSL encrpytion in Global settings/Security after SSL is properly configured for your webserver.

 nameserver ns-1817.awsdns-35.co.uk ns-19.awsdns-02.com ns-781.awsdns-33.net ns-1062.awsdns-04.org

 3.8.215.123

  'connectionString' => 'mysql:host=pollster.cw0ko9icjnut.eu-west-2.rds.amazonaws.com;port=3306;dbname=pollster;',
                        'emulatePrepare' => true,
                        'username' => 'admin',
                        'password' => 'l1m3surv3y',
                        'charset' => 'utf8mb4',
                        'tablePrefix' => 'lime_',
                        