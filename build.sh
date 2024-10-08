#!/bin/bash
set -xe
PLAIN_NAME=lrp-archiva
IMG_NAME=cga-ci:5000/$PLAIN_NAME

docker build --pull -t $IMG_NAME .

# Tag and push if given
if [ "$1" = "push" ]; then
    docker push $IMG_NAME
fi
