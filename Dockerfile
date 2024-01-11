FROM alpine

RUN apk update && apk add --no-cache \
    bash \
    curl \
    openssh-client
ADD rootfs /

ENTRYPOINT ["/docker-entrypoint.sh"]
