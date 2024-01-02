#!/bin/bash
set -e
ME=$(basename "$0")
REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
PRIVATE_KEY_FILE="/run/secrets/key"
PUBLIC_KEY_FILE="/run/secrets/key.pub"
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-60}"
SSH_STRICT_HOST_KEY_CHECKING="${SSH_STRICT_HOST_KEY_CHECKING:-yes}"
SSH_SERVER_ALIVE_INTERVAL="${SSH_SERVER_ALIVE_INTERVAL:-30}"
SSH_SERVER_ALIVE_COUNT_MAX="${SSH_SERVER_ALIVE_COUNT_MAX:-10000}"

entrypoint_log() {
	echo "$ME: $*"
}

# Check if the first argument is "bash" or "/bin/bash"
if [ "$1" = "bash" ] || [ "$1" = "/bin/bash" ]; then
	exec "$@"
fi

# Check if the first argument is "sh" or "/bin/sh"
if [ "$1" = "sh" ] || [ "$1" = "/bin/sh" ]; then
	exec "$@"
fi

if [ ! -f "$PRIVATE_KEY_FILE" ]; then
	entrypoint_log "ERROR: Unable to find private key file"
	entrypoint_log "       Please mount your private key file to $PRIVATE_KEY_FILE"
	exit 1
fi

entrypoint_log "INFO: Fetching public key from host $REMOTE_HOST..."
ssh-keyscan "$REMOTE_HOST" > /etc/ssh/ssh_known_hosts
cat /etc/ssh/ssh_known_hosts | while read line; do
	entrypoint_log "INFO: Added host key: $line"
done

entrypoint_log "INFO: Checking private key file..."
ssh-keygen -lvf "$PRIVATE_KEY_FILE"

entrypoint_log "INFO: Starting ssh proxy to $REMOTE_TARGET..."
CMD_FLAGS=()
CMD_FLAGS+=("-o" "ConnectTimeout=${SSH_CONNECT_TIMEOUT}")
CMD_FLAGS+=("-o" "StrictHostKeyChecking=${SSH_STRICT_HOST_KEY_CHECKING}")
CMD_FLAGS+=("-o" "ServerAliveInterval=${SSH_SERVER_ALIVE_INTERVAL}")
CMD_FLAGS+=("-o" "ServerAliveCountMax=${SSH_SERVER_ALIVE_COUNT_MAX}")
CMD_FLAGS+=("-o" "ExitOnForwardFailure=yes")
CMD_FLAGS+=("-i" "$PRIVATE_KEY_FILE")
CMD_FLAGS+=("-NT")
set -x
exec ssh "${CMD_FLAGS[@]}" "$@" "${REMOTE_TARGET}"
