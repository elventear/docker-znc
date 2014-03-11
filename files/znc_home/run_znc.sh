#!/bin/bash

set -e

HOME=/home/znc
ZNC=/usr/bin/znc
ZNC_DATA=$HOME/.znc
ZNC_CONFIG=$ZNC_DATA/configs/znc.conf
ZNC_TEMPLATE=$ZNC_DATA/configs/znc.template

if [[ ! -f $ZNC_DATA/znc.pem ]]; then 
    $ZNC -d $ZNC_DATA -p
    echo Created new SSL certificate
fi

if [ ! -f $ZNC_CONFIG ]; then
    if [ -z $ZNC_ADMIN_PASS ]; then
        echo Please provide a password for the 'admin' user via the ZNC_ADMIN_PASS enviroment variable.
        exit 1
    fi
    ZNC_SALT="$(dd if=/dev/urandom bs=16c count=1 | md5sum | awk '{print $1}')"
    ZNC_HASH="$(echo -n ${ZNC_ADMIN_PASS}${ZNC_SALT} | sha256sum | awk '{print $1}')"
    sed -e "s/@hash@/$ZNC_HASH/g" -e "s/@salt@/$ZNC_SALT/g" $ZNC_TEMPLATE > $ZNC_CONFIG
fi 

unset $ZNC_ADMIN_PASS

exec $ZNC -f -d $ZNC_DATA
