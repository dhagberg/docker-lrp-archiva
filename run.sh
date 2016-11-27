#!/bin/bash
set -xe
exec docker run -d --name archiva \
    -v /tank/archiva:/var/archiva:Z \
    -p 9999:9999 \
    --restart always \
    dhagberg/co811-archiva:latest
