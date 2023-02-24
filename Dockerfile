FROM svn.co811.org:5000/lrp-java

MAINTAINER D. J. Hagberg <dhagberg@millibits.com>

ENV ARCHIVA_VERSION 2.2.9
ENV ARCHIVA_SHA2 183f00be4b05564e01c9a4687b59d81828d9881c55289e0a2a9c1f903afb0c93
ENV ARCHIVA_BASE /var/archiva

RUN set -xe \
  && wget -q -O /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
    http://apache.mirrors.pair.com/archiva/$ARCHIVA_VERSION/binaries/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
  && sha256sum /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
  && mkdir -p /opt \
  && echo "$ARCHIVA_SHA2 /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz" | sha256sum -c - \
  && tar -zxf /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz -C /opt/ \
  && rm /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz

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
