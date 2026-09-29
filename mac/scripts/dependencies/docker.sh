#!/bin/sh

set -e
set -o pipefail

echo "***Configuring Docker detach keys***"

# Docker's default detach sequence is ctrl-p,ctrl-q, so `docker exec -it`
# holds back every ctrl-p until the next key arrives. Move it somewhere
# unused so ctrl-p works on the first press inside devcontainers.
# Merge rather than symlink: config.json also holds registry credentials.
DOCKER_CONFIG_FILE="$HOME/.docker/config.json"
DETACH_KEYS="ctrl-],ctrl-]"

mkdir -p "$(dirname "$DOCKER_CONFIG_FILE")"
[ -s "$DOCKER_CONFIG_FILE" ] || echo '{}' > "$DOCKER_CONFIG_FILE"

tmp_file=$(mktemp)
jq --arg keys "$DETACH_KEYS" '.detachKeys = $keys' "$DOCKER_CONFIG_FILE" > "$tmp_file"
cat "$tmp_file" > "$DOCKER_CONFIG_FILE"
rm "$tmp_file"
