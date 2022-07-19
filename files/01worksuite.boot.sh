#!/usr/bin/env bash

set -e

echo "root:$ROOT_PASSWORD" | chpasswd
echo "ubuntu:$ROOT_PASSWORD" | chpasswd

rm -rf           "${WORKINGDIR}"
mkdir -p "${WD}"
ln -s    "${WD}" "${WORKINGDIR}"

if [ "$CRON" = true ] ; then
    export START_CRON=1
fi
