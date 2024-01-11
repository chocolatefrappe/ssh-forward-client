FROM alpine

RUN apk update && apk add --no-cache \
    bash \
    curl \
    openssh-client \
    ssh-import-id

# https://github.com/socheatsok78/s6-overlay-installer
ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG S6_OVERLAY_INSTALLER=main/s6-overlay-installer-minimal.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/socheatsok78/s6-overlay-installer/${S6_OVERLAY_INSTALLER})"

# https://github.com/vishnubob/wait-for-it
ADD --chmod=0755 https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it

ADD rootfs /
ENTRYPOINT [ "/init-shim", "/docker-entrypoint.sh"]
VOLUME [ "/keys.d" ]
