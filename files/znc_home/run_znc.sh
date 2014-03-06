#!/bin/bash

set -e

HOME=/home/znc
ZNC=/usr/bin/znc
ZNC_DATA=$HOME/.znc
ZNC_CONFIG=$ZNC_DATA/configs/znc.conf
ZNC_TEMPLATE=$ZNC_DATA/configs/znc.template

genpass () {
	local num_char=$1
	test -z $num_char && num_char=15
	local tmp=$LC_ALL
	export LC_ALL=C
	echo $(cat /dev/urandom | tr -dc '[:alnum:][:punct:]' | head -c${num_char})
	export LC_ALL=$tmp
}

if [[ ! -f $ZNC_DATA/znc.pem ]]; then 
    $ZNC -d $ZNC_DATA -p
    echo Created new SSL certificate
fi

if [ ! -f $ZNC_TEMPLATE ]; then
    if [ -z $ZNC_ADMIN_PASS ]; then
        ZNC_ADMIN_PASS=$(genpass 20)
        echo Auto generated Admin password $ZNC_ADMIN_PASS
    else
        echo Using provided password
    fi
    ZNC_SALT="$(dd if=/dev/urandom bs=16c count=1 | md5sum | awk '{print $1}')"
    ZNC_HASH="$(echo -n ${ZNC_PASS}${ZNC_SALT} | sha256sum | awk '{print $1}')"
    sed -e "s/@hash@/$ZNC_HASH/g" -e "s/@salt@/$ZNC_SALT/g" $ZNC_TEMPLATE > $ZNC_CONFIG
    cat $ZNC_CONFIG
fi 

exec $ZNC -f -d $ZNC_DATA
