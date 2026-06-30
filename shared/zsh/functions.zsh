# Run the Claude Code /standup command, showing a spinner while it works
# (claude -p buffers all output until it finishes, so without this the
# terminal just sits blank).
standup() {
  # Suppress zsh's "[2] 27041" job-control notification for the background
  # job below. local_options reverts this when the function returns.
  setopt local_options no_monitor
  local tmp rc
  tmp=$(mktemp)
  claude -p "/standup" >"$tmp" 2>&1 &
  local pid=$!

  # Only animate when stderr is an interactive terminal.
  if [[ -t 2 ]]; then
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) i=1
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r%s generating standup…' "${frames[i]}" >&2
      i=$(( i % ${#frames} + 1 ))
      sleep 0.1
    done
    printf '\r\033[K' >&2  # clear the spinner line
  fi

  wait "$pid"; rc=$?
  cat "$tmp"
  command rm -f "$tmp"  # bypass the `rm -v` alias so the path isn't echoed
  return $rc
}
