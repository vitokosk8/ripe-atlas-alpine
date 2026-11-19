FROM alpine:latest AS builder
# Pinned upstream commit (master at the time of the pin, VERSION 5130).
# Override with --build-arg PROBE_REF=<tag-or-commit> to build another release.
ARG PROBE_REF=9eba070abb1db98890b45e5e531765ac8a11ed97
RUN apk add --no-cache autoconf automake g++ gcc git libtool linux-headers make openssl-dev patch sed &&\
 git clone --recursive https://github.com/RIPE-NCC/ripe-atlas-software-probe.git &&\
 cd ripe-atlas-software-probe/ &&\
 git checkout "${PROBE_REF}" &&\
 git submodule update --init --recursive &&\
 autoreconf -iv &&\
 ./configure --prefix=/probe --disable-chown --disable-setcap-install --disable-systemd &&\
 make install

FROM alpine:latest AS probe
ARG REVISION
ARG VERSION
LABEL org.opencontainers.image.authors="vitokosk8" \
 org.opencontainers.image.description="Docker images of RIPE Atlas Software Probe using Alpine Linux" \
 org.opencontainers.image.licenses="GPL-3.0" \
 org.opencontainers.image.revision="$REVISION" \
 org.opencontainers.image.source="https://github.com/vitokosk8/ripe-atlas-alpine" \
 org.opencontainers.image.title="ripe-atlas-alpine" \
 org.opencontainers.image.url="https://github.com/vitokosk8/ripe-atlas-alpine" \
 org.opencontainers.image.vendor="vitokosk8" \
 org.opencontainers.image.version="$VERSION"
COPY --from=builder /probe /probe
RUN apk add --no-cache libcap net-tools openssh tini &&\
 adduser -D ripe-atlas &&\
 setcap cap_net_raw=ep /probe/libexec/ripe-atlas/measurement/busybox
WORKDIR /probe
VOLUME ["/probe/etc/ripe-atlas", "/probe/var/run/ripe-atlas/status"]
# "/probe/var/spool/ripe-atlas/data" can also be defined as a volume, but it is optional
ENTRYPOINT ["/sbin/tini", "--"]
CMD [ ! -f /probe/etc/ripe-atlas/config.txt ] && echo "RXTXRPT=yes" > /probe/etc/ripe-atlas/config.txt ;\
 [ ! -f /probe/etc/ripe-atlas/mode ] && echo "prod" > /probe/etc/ripe-atlas/mode ;\
 [ -f /probe/etc/ripe-atlas/reg_servers.sh ] && rm /probe/etc/ripe-atlas/reg_servers.sh ;\
 /probe/sbin/ripe-atlas
