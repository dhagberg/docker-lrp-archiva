FROM cga-ci:5000/lrp-u-base:latest
# NOTE still start from lrp ubuntu base so we can install zulu8 rather than zulu21

MAINTAINER D. J. Hagberg <dhagberg@millibits.com>

ENV ARCHIVA_VERSION 2.2.10
ENV ARCHIVA_SHA2 9d468f5cd3d7f6841e133e853fc24e73fb62397091f1bb3601b6f157a5eadf77
ENV ARCHIVA_BASE /var/archiva

RUN set -xe \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install zulu8-jre-headless fontconfig fonts-dejavu-core fonts-dejavu-mono wget \
  && fname=apache-archiva-${ARCHIVA_VERSION}-bin.tar.gz \
  && wget -q -O /tmp/$fname \
    https://archive.apache.org/dist/archiva/${ARCHIVA_VERSION}/binaries/$fname \
  && sha256sum /tmp/$fname \
  && mkdir -p /opt \
  && echo "$ARCHIVA_SHA2 /tmp/$fname" | sha256sum -c - \
  && tar -zxf /tmp/$fname -C /opt/ \
  && rm /tmp/$fname

RUN groupadd -g 799 archiva \
  && useradd --comment Archiva -g 799 -u 799 archiva

WORKDIR /opt/apache-archiva-$ARCHIVA_VERSION

RUN set -xe \
  && sed -i -e "/set.default.ARCHIVA_BASE/c\set.default.ARCHIVA_BASE=$ARCHIVA_BASE" \
      -e '/^wrapper.java.additional.8=/a wrapper.java.additional.9=-Djetty.port=%ARCHIVA_PORT%' \
      conf/wrapper.conf \
  && mkdir -p $ARCHIVA_BASE/logs $ARCHIVA_BASE/data $ARCHIVA_BASE/temp $ARCHIVA_BASE/conf \
  && rm bin/wrapper-linux-x86-32 bin/wrapper-mac* bin/wrapper-sol* bin/wrapper-win* \
  && mv conf/* $ARCHIVA_BASE/conf \
  && chown -R archiva:archiva $ARCHIVA_BASE \
  && chown -R root:archiva /opt/apache-archiva-$ARCHIVA_VERSION \
  && echo "temp fix because ARCHIVA_BASE is not use by archiva :(" \
  && rmdir logs conf temp \
  && ln -s $ARCHIVA_BASE/logs logs \
  && ln -s $ARCHIVA_BASE/conf conf \
  && ln -s $ARCHIVA_BASE/data data \
  && ln -s $ARCHIVA_BASE/temp temp

VOLUME /var/archiva
USER archiva

ENV ARCHIVA_PORT 9999
EXPOSE 9999
CMD ./bin/archiva console
