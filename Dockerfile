FROM debian:bullseye-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# LABEL \
    

ENV \
    BIND_PRIV=false \
    DEBIAN_FRONTEND=noninteractive \
    DEBUG=false \
    JVM_EXTRA_OPTS= \
    JVM_INIT_HEAP_SIZE= \
    JVM_MAX_HEAP_SIZE=1024M \
    PGID=999 \
    PUID=999 \
    RUN_CHOWN=true \
    RUNAS_UID0=false

WORKDIR /usr/lib/unifi

COPY root /

R
    
        ca-certificates-java > /dev/null \
    && apt-get -qqy --no-install-recommends install \
        openjdk-17-jre-headless > /dev/null \
    && curl -fsSL https://pgp.mongodb.com/server-5.0.asc | \
        gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg \
        --dearmor \
    && echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" \
        > /etc/apt/sources.list.d/mongodb-org-5.0.list \
    && apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        mongodb-org-server > /dev/null \
    && curl -sSL https://dl.ui.com/unifi/${VERSION}/unifi_sysvinit_all.deb -o /tmp/unifi-${VERSION}.deb \
    && apt-get -qqy purge \
        apt-utils dirmngr gnupg2 > /dev/null \
    

EXPOSE 3478/udp 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 10001/udp

VOLUME ["/usr/lib/unifi/cert", "/usr/lib/unifi/data", "/usr/lib/unifi/logs"]

HEALTHCHECK --start-period=2m CMD /usr/local/bin/docker-healthcheck.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["unifi"]
