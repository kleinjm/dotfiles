#!/usr/bin/env bash
# Reapplies plugins.json and settings.json (written by export.sh) to a running
# bb. Run inside the locky container once bb is up. Idempotent: installed
# plugins are skipped and settings are set to the same value again.
#
# Restore after locky's own provisioning (bin/locky up), never before: wtm and
# the escrowsafe theme come from web/.locky, and the path source in
# plugins.json only resolves once that checkout is mounted.
set -uo pipefail
cd "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

failures=0
try() { # <description> <command...>
  local what="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "✓ $what"
  else
    echo "✗ $what"
    failures=$((failures + 1))
  fi
}

installed=$(bb plugin list --json | jq -r '.plugins[].id')

while read -r id source; do
  if grep -qx "$id" <<<"$installed"; then
    echo "· $id already installed"
  else
    try "install $id" bb plugin install "$source" --yes
  fi
done < <(jq -r '.installed[] | "\(.id) \(.source)"' plugins.json)

while read -r id enabled; do
  current=$(bb plugin list --json | jq -r --arg id "$id" '.plugins[] | select(.id == $id) | .enabled')
  [ -z "$current" ] || [ "$current" = "$enabled" ] && continue
  if [ "$enabled" = true ]; then
    try "enable $id" bb plugin enable "$id"
  else
    try "disable $id" bb plugin disable "$id"
  fi
done < <(jq -r '.enabled | to_entries[] | "\(.key) \(.value)"' plugins.json)

theme=$(jq -r '.theme.id // empty' settings.json)
favicon=$(jq -r '.theme.faviconColor // empty' settings.json)
if [ -n "$theme" ]; then
  try "theme $theme" bb theme set "$theme" ${favicon:+--favicon-color "$favicon"}
fi

# Values go through as JSON so lists and null survive; plain strings are
# passed bare because `bb settings` reads an unquoted word as a string.
as_arg() { jq -r 'if type == "string" then . else tojson end'; }

while IFS= read -r key; do
  value=$(jq --arg k "$key" '.ui[$k]' settings.json | as_arg)
  try "ui $key" bb settings ui set "$key" "$value"
done < <(jq -r '.ui | keys[]' settings.json)

while IFS= read -r key; do
  value=$(jq --arg k "$key" '.general[$k]' settings.json | as_arg)
  # `bb settings show` reports a few read-only keys that `general` rejects.
  if out=$(bb settings general "$key" "$value" 2>&1); then
    echo "✓ general $key"
  elif grep -q "Unknown general setting" <<<"$out"; then
    echo "· general $key is read-only, skipped"
  else
    echo "✗ general $key"
    failures=$((failures + 1))
  fi
done < <(jq -r '.general | keys[]' settings.json)

while read -r command shortcut; do
  try "shortcut $command" bb settings keyboard set "$command" "$shortcut"
done < <(jq -r '.keyboard[]? | "\(.command) \(.shortcut)"' settings.json)

if [ "$failures" -gt 0 ]; then
  echo "$failures step(s) failed; rerun with the failing bb command to see why"
  exit 1
fi
