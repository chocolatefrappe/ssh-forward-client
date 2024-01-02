#!/bin/bash
set -e
REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
PRIVATE_KEY_FILE="/run/secrets/key"
PUBLIC_KEY_FILE="/run/secrets/key.pub"
SSH_STRICT_HOST_KEY_CHECKING="${SSH_STRICT_HOST_KEY_CHECKING:-yes}"
SSH_SERVER_ALIVE_INTERVAL="${SSH_SERVER_ALIVE_INTERVAL:-30}"
SSH_SERVER_ALIVE_COUNT_MAX="${SSH_SERVER_ALIVE_COUNT_MAX:-10000}"

# Check if the first argument is "bash" or "/bin/bash"
if [ "$1" = "bash" ] || [ "$1" = "/bin/bash" ]; then
	exec "$@"
fi

# Check if the first argument is "sh" or "/bin/sh"
if [ "$1" = "sh" ] || [ "$1" = "/bin/sh" ]; then
	exec "$@"
fi

if [ ! -f "$PRIVATE_KEY_FILE" ]; then
	echo "ERROR: Unable to find private key file"
	echo "       Please mount your private key file to $PRIVATE_KEY_FILE"
	exit 1
fi

echo "INFO: Fetching public key from $REMOTE_HOST"
ssh-keyscan "$REMOTE_HOST" >> /etc/ssh/ssh_known_hosts

echo "INFO: Starting ssh tunnel to $REMOTE_TARGET"
set -x
exec ssh -NT \
	-i "$PRIVATE_KEY_FILE" \
		-o StrictHostKeyChecking=${SSH_STRICT_HOST_KEY_CHECKING} \
		-o IdentitiesOnly=yes \
		-o ServerAliveInterval=${SSH_SERVER_ALIVE_INTERVAL} \
		-o ServerAliveCountMax=${SSH_SERVER_ALIVE_COUNT_MAX} \
		-o ExitOnForwardFailure=yes \
	"$@" \
	"${REMOTE_TARGET}"
