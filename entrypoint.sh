#!/bin/sh

DST="/opt"
mkdir -p $DST
cd $DST

if [ ! -f "${HOST}.mobileconfig" ]; then
  generate-mobileconfig > "${HOST}".mobileconfig
fi

exec "$@"
