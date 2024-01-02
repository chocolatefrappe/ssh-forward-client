FROM alpine

RUN apk update && apk add --no-cache bash openssh-client
ADD rootfs /

ENTRYPOINT ["/docker-entrypoint.sh"]
