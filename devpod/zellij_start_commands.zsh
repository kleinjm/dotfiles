# Zellij session/layout start commands
# Usage: zstart <name>
# Starts zellij with the named layout and session

zstart() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo "Usage: zstart <name>"
        echo "Available layouts:"
        ls -1 ~/.config/zellij/layouts/*.kdl 2>/dev/null | xargs -n1 basename | sed 's/\.kdl$//'
        return 1
    fi

    local layout_file="${HOME}/.config/zellij/layouts/${name}.kdl"

    if [[ ! -f "$layout_file" ]]; then
        echo "Layout '${name}' not found at ${layout_file}"
        echo "Available layouts:"
        ls -1 ~/.config/zellij/layouts/*.kdl 2>/dev/null | xargs -n1 basename | sed 's/\.kdl$//'
        return 1
    fi

    zellij --layout "$name" --session "$name"
}
