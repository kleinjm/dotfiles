#!/usr/bin/env bash
# Writes bb's restorable configuration next to this script: the plugins
# installed on top of bb's built-ins, every plugin's enabled state, and the
# settings changed from their defaults. Run inside the locky container.
#
# Never exports auth.json, auth-secret, plugin tokens or bb.db: those are
# credentials or state, not configuration.
set -euo pipefail
cd "$(dirname -- "${BASH_SOURCE[0]}")"

bb plugin list --json | jq '{
  installed: [.plugins[] | select(.provenance != "builtin") | {id, source, enabled}] | sort_by(.id),
  enabled: [.plugins[] | {(.id): .enabled}] | add
}' >plugins.json

settings=$(bb settings show --json)
ui=$(bb settings ui list --json)
keyboard=$(bb settings keyboard list --json)

jq -n \
  --argjson s "$settings" --argjson ui "$ui" --argjson kb "$keyboard" '{
    general: $s.generalSettings,
    theme: {id: $s.appearance.themeId, faviconColor: $s.appearance.faviconColor},
    ui: [$ui.preferences | to_entries[] | select(.value.revision > 0) | {(.key): .value.value}] | add // {},
    keyboard: $kb.overrides
  }' >settings.json

echo "✓ wrote $(pwd)/plugins.json and settings.json"
