FROM java:8-jre

MAINTAINER D. J. Hagberg <dhagberg@millibits.com>

ENV ARCHIVA_VERSION 2.2.3
ENV ARCHIVA_SHA1 1ada30e1fcacc88b07b0bf831fb3becd27b94d46
ENV ARCHIVA_BASE /var/archiva

RUN set -xe \
  && wget -q -O /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
    http://apache.mirrors.pair.com/archiva/$ARCHIVA_VERSION/binaries/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
  && sha1sum /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz \
  && mkdir -p /opt \
  && echo "$ARCHIVA_SHA1 /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz" | sha1sum -c - \
  && tar -zxf /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz -C /opt/ \
  && rm /tmp/apache-archiva-$ARCHIVA_VERSION-bin.tar.gz

RUN addgroup --gid 799 archiva \
  && adduser --gecos Archiva --gid 799 --uid 799 --disabled-password archiva

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
