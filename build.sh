#!/bin/bash
set -xe
# Get latest centos
docker pull java:8-jre
# Run build
docker build -t dhagberg/co811-archiva .
