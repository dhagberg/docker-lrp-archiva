#!/bin/bash
set -xe
prevrun=$(docker inspect -f '{{.State.Running}}' archiva \
    2>/dev/null || true)
case "$prevrun" in
    true)  docker stop archiva; docker rm archiva ;;
    false) docker rm archiva ;;
esac
exec docker run -d --name archiva \
    -v /tank/archiva:/var/archiva:Z \
    -p 9999:9999 \
    --restart unless-stopped \
    cga-ci:5000/lrp-archiva:latest
