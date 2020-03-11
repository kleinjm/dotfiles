#!/usr/bin/env bash

# Places the given arg into the next shell line.
# Useful for tmuxinator to start a pane without executing the command.
type_cmd="osascript -e 'tell application \"System Events\" to keystroke \"%s\"'"

printf "$type_cmd %s" "$1" | sh
