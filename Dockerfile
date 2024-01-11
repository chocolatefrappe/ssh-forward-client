FROM alpine

RUN apk update && apk add --no-cache \
    bash \
    curl \
    openssh-client

# https://github.com/socheatsok78/s6-overlay-installer
ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG S6_OVERLAY_INSTALLER=main/s6-overlay-installer-minimal.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/socheatsok78/s6-overlay-installer/${S6_OVERLAY_INSTALLER})"

ADD rootfs /
ENTRYPOINT [ "/init-shim", "/docker-entrypoint.sh"]
