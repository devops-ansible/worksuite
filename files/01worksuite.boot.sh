#!/usr/bin/env bash
set -e

echo "root:$ROOT_PASSWORD" | chpasswd
echo "ubuntu:$ROOT_PASSWORD" | chpasswd

if [ "$CRON" = true ] ; then
    export START_CRON=1
fi
