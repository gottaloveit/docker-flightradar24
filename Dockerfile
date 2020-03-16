FROM debian:stable-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    BEASTPORT=30005 \
    MLAT=no
# MLAT needs to be set to 'no' due to a segfault issue with fr24feed

COPY deploy_fr24feed.sh /tmp/deploy_fr24feed.sh

RUN set -x && \
    echo "========== Prerequisites ==========" && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        binutils \
        procps \
        ca-certificates \
        curl \
        gnupg \
        file \
        xmlstarlet && \
    echo "========== Deploying s6-overlay ==========" && \
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    echo "========== Deploying fr24feed ==========" && \
    /tmp/deploy_fr24feed.sh && \
    echo "========== Clean-up ==========" && \
    apt-get remove -y \
        curl \
        gnupg \
        file \
        xmlstarlet && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY etc/ /etc/

EXPOSE 30334/tcp 8754/tcp 30003/tcp

ENTRYPOINT [ "/init" ]
