#!/bin/bash
set -xe
PLAIN_NAME=lrp-archiva
SVN_NAME=svn.co811.org:5000/$PLAIN_NAME

docker build --pull -t $SVN_NAME .

# Tag and push if given
if [ "$1" = "push" ]; then
    docker push $SVN_NAME
fi
