# Zellij session/layout start commands
# Usage: zstart <name>
# Attaches to existing session or creates one using the corresponding layout

zstart() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo "Usage: zstart <name>"
        echo "Available layouts:"
        for f in ~/.config/zellij/layouts/*.kdl; do
            [[ -f "$f" ]] && basename "$f" .kdl
        done
        return 1
    fi

    # Check if session already exists
    if zellij list-sessions --short 2>/dev/null | grep -qx "$name"; then
        zellij attach "$name"
        return
    fi

    # Session doesn't exist - check for layout and create
    local layout_file="${HOME}/.config/zellij/layouts/${name}.kdl"

    if [[ ! -f "$layout_file" ]]; then
        echo "Session '${name}' not found and no layout at ${layout_file}"
        echo "Available layouts:"
        for f in ~/.config/zellij/layouts/*.kdl; do
            [[ -f "$f" ]] && basename "$f" .kdl
        done
        return 1
    fi

    zellij -n "$name" -s "$name"
}
