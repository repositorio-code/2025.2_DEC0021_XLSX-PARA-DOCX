#!/usr/bin/env bash
set -euo pipefail

# Enhanced runner for n8n with automatic build, .env loading and persistent storage at "n8n-data:/home/node/.n8n"
# - Builds local Docker image from the Dockerfile in this directory if it's missing
# - Loads environment variables from ./ .env when present (passed to the container)
# - Uses a named volume from .env (N8N_VOLUME_NAME) or falls back to ./n8n-data host dir

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="n8n-custom"
IMAGE_NAME="n8n-custom:local"
ENV_FILE="$SCRIPT_DIR/.env"

set -a
source "$ENV_FILE"
set +a

# Helper: print to stderr
err() { printf '%s\n' "$*" >&2; }

# Load .env if present (we'll still pass --env-file when running)
if [ -f "$ENV_FILE" ]; then
	# shellcheck disable=SC1090
	set -a
	# load without polluting the environment if variables are not valid shell assignments
	# use a subshell to avoid exporting everything here — we only need to detect N8N_VOLUME_NAME
	N8N_VOLUME_NAME=$(grep -E '^N8N_VOLUME_NAME=' "$ENV_FILE" | tail -n1 | cut -d'=' -f2- || true)
	set +a
else
	N8N_VOLUME_NAME=""
fi

# Determine data mount: prefer Docker named volume from N8N_VOLUME_NAME, else use host dir ./n8n-data
if [ -n "$N8N_VOLUME_NAME" ]; then
	DATA_MOUNT="${N8N_VOLUME_NAME}:/home/node/.n8n"
	DATA_IS_VOLUME=true
else
	HOST_DATA_DIR="$SCRIPT_DIR/n8n-data"
	mkdir -p "$HOST_DATA_DIR"
	DATA_MOUNT="$HOST_DATA_DIR:/home/node/.n8n"
	DATA_IS_VOLUME=false
fi

# Build image if missing
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
	echo "[i] Local image '$IMAGE_NAME' not found — building from Dockerfile in $SCRIPT_DIR"
	(cd "$SCRIPT_DIR" && docker build -t "$IMAGE_NAME" .)
else
	echo "[i] Using existing image '$IMAGE_NAME'"
fi

# Stop and remove existing container if present
if docker ps -a --format '{{.Names}}' | grep -x "$CONTAINER_NAME" >/dev/null 2>&1; then
	echo "[i] Stopping and removing existing container '$CONTAINER_NAME'"
	docker rm -f "$CONTAINER_NAME" >/dev/null || true
fi

# Allow passing extra docker run args via CLI
EXTRA_ARGS=()
if [ "$#" -gt 0 ]; then
	EXTRA_ARGS=("$@")
fi

# Build docker run command
DOCKER_RUN=(docker run -d --name "$CONTAINER_NAME" -p ${HOST_PORT}:5678 -v "$DATA_MOUNT")

# If there is an env file, pass it through
if [ -f "$ENV_FILE" ]; then
	DOCKER_RUN+=(--env-file "$ENV_FILE")
fi

# Add restart policy and any extra args
DOCKER_RUN+=(--restart unless-stopped)
DOCKER_RUN+=("${EXTRA_ARGS[@]}")

# Image and default command
DOCKER_RUN+=("$IMAGE_NAME")

echo "[i] Running container with: ${DOCKER_RUN[*]}"
"${DOCKER_RUN[@]}"

echo "[i] Container '$CONTAINER_NAME' started."

# Run setup.sh
echo "[i] Running setup.sh..."
./setup.sh