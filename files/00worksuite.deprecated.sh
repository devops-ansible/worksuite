#!/usr/bin/env bash

set -e

echo "root:$ROOT_PASSWORD"   | chpasswd
echo "ubuntu:$ROOT_PASSWORD" | chpasswd
