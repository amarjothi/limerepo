#!/usr/bin/env bash

#apachectl -t -S -D DUMP_INCLUDES > test.out
#cat test.out

TARGET_GID=$(stat -c "%g" /var/log/apache2/)
EXISTS=$(cat /etc/group | grep $TARGET_GID | wc -l)

# Create new group using target GID and add nobody user
if [ $EXISTS == "0" ]; then
    groupadd -g $TARGET_GID www-data
    usermod -a -G www-data www-data
else
# GID exists, find group name and add
    GROUP=$(getent group $TARGET_GID | cut -d: -f1)
    usermod -a -G $GROUP www-data
fi

TARGET_GID=$(stat -c "%g" /var/run)
EXISTS=$(cat /etc/group | grep $TARGET_GID | wc -l)

# Create new group using target GID and add nobody user
if [ $EXISTS == "0" ]; then
    groupadd -g $TARGET_GID www-data
    usermod -a -G www-data www-data
else
# GID exists, find group name and add
    GROUP=$(getent group $TARGET_GID | cut -d: -f1)
    usermod -a -G $GROUP www-data
fi