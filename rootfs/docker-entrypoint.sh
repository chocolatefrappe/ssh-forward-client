#!/bin/bash
set -e
ME=$(basename "$0")

REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
REMOTE_PORT="${REMOTE_PORT}"
REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}"

# SSH Client configuration
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-60}"
SSH_STRICT_HOST_KEY_CHECKING="${SSH_STRICT_HOST_KEY_CHECKING:-yes}"
SSH_SERVER_ALIVE_INTERVAL="${SSH_SERVER_ALIVE_INTERVAL:-30}"
SSH_SERVER_ALIVE_COUNT_MAX="${SSH_SERVER_ALIVE_COUNT_MAX:-10000}"

# Container Secrets
PRIVATE_KEY_FILE="${PRIVATE_KEY_FILE:-/run/secrets/key}"
SSH_KNOWN_HOSTS_FILE=${SSH_KNOWN_HOSTS_FILE:-/run/secrets/known_hosts}

# Default
DEFAULT_SSH_KNOWN_HOSTS_FILE="/etc/ssh/ssh_known_hosts"

entrypoint_log() {
	echo "$ME: $*"
}

entrypoint_log_n() {
	echo -n "$ME: $*"
}

entrypoint_exit() {
	local exit_code=$1
	entrypoint_log "ERROR: Exiting... (code: $exit_code)"
	exit $exit_code
}

# Check if the first argument is "bash" or "/bin/bash"
if [ "$1" = "bash" ] || [ "$1" = "/bin/bash" ]; then
	exec "$@"
fi

# Check if the first argument is "sh" or "/bin/sh"
if [ "$1" = "sh" ] || [ "$1" = "/bin/sh" ]; then
	exec "$@"
fi

# Print banner
test -f "/etc/ssh/banner" && cat "/etc/ssh/banner"

# Check pre-requisites environment variables
if [ "$REMOTE_USER" = "" ] || [ "$REMOTE_HOST" = "" ]; then
	entrypoint_log "ERROR: Please set REMOTE_USER and REMOTE_HOST environment variables."
	entrypoint_exit 1
fi

# Check if private key file exists
if [ ! -f "$PRIVATE_KEY_FILE" ]; then
	entrypoint_log "ERROR: Unable to find private key file, PRIVATE_KEY_FILE=${PRIVATE_KEY_FILE}."
	entrypoint_log "       Please mount your private key file to the container and set PRIVATE_KEY_FILE environment variable"
	entrypoint_log "       or mount using use container secrets."
	entrypoint_exit 2
fi

# Allow adding custom known_hosts file from container secrets
if [ -f "${SSH_KNOWN_HOSTS_FILE}" ]; then
{
	entrypoint_log "INFO: Using known_hosts file from container secrets (SSH_KNOWN_HOSTS_FILE=${SSH_KNOWN_HOSTS_FILE})..."
	test -f "${DEFAULT_SSH_KNOWN_HOSTS_FILE}" && rm "${DEFAULT_SSH_KNOWN_HOSTS_FILE}"
	cp "${SSH_KNOWN_HOSTS_FILE}" "${DEFAULT_SSH_KNOWN_HOSTS_FILE}"
}
else
{
	SSH_KEYSCAN_FLAGS=()
	test -n "${REMOTE_PORT}" && SSH_KEYSCAN_FLAGS+=("-p" "${REMOTE_PORT}")
	entrypoint_log_n "INFO: Waiting for remote host to be ready... "
	if wait-for-it -q -t 15 "${REMOTE_HOST}:${REMOTE_PORT:-22}"; then
		echo "[READY]"
	else
		echo "[NOT READY]"
		entrypoint_log "ERROR: Remote (${REMOTE_HOST}:${REMOTE_PORT:-22}) is not ready, please check your connection and try again!"
		entrypoint_exit 3
	fi
	entrypoint_log "============================== !!! Warning !!! =============================="
	entrypoint_log "   Scanning host keys from: $REMOTE_HOST:${REMOTE_PORT:-22}..."
	entrypoint_log ""
	entrypoint_log "   This is not recommended and should only be used for testing purposes,"
	entrypoint_log "   Please provide a known_hosts file using container secrets or volume."
	entrypoint_log "============================================================================="
	ssh-keyscan "${SSH_KEYSCAN_FLAGS[@]}" "$REMOTE_HOST" > /etc/ssh/ssh_known_hosts
	cat /etc/ssh/ssh_known_hosts | while read line; do
		entrypoint_log "INFO: Added host key: $line"
	done
}
fi

{
	entrypoint_log "INFO: Checking private key file..."
	ssh-keygen -lvf "$PRIVATE_KEY_FILE"
}

entrypoint_log "INFO: Starting ssh proxy service..."
CMD_FLAGS=(
	-o ConnectTimeout=${SSH_CONNECT_TIMEOUT}
	-o StrictHostKeyChecking=${SSH_STRICT_HOST_KEY_CHECKING}
	-o ServerAliveInterval=${SSH_SERVER_ALIVE_INTERVAL}
	-o ServerAliveCountMax=${SSH_SERVER_ALIVE_COUNT_MAX}
	-i $PRIVATE_KEY_FILE
	-NT
)
test -n "${REMOTE_PORT}" && CMD_FLAGS+=("-p" "${REMOTE_PORT}")

set -x
exec ssh "${CMD_FLAGS[@]}" "$@" "${REMOTE_TARGET}"
