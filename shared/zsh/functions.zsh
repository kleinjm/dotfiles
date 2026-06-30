# fd - fzf cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# chist - browse chrome history
chist() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]lugin
bip() {
  local inst=$(brew search | fzf -m)

  if [[ $inst ]]; then
    for prog in $(echo $inst);
    do; brew install $prog; done;
  fi
}

# Change the heat using radio thermostat for the upstairs bedrooms
heat() {
  curl -H 'Host: my.radiothermostat.com' -H 'Content-Type: application/json; charset=utf-8' -H 'X-Mobile-Auth: 37d560b9274fe1e1fb9de68552fa5e1c' -H 'Cookie: JSESSIONID=FA96C476E5DAFC3676BFC3D4E9A1A0A0' -H 'Accept: application/json' -H 'User-Agent: Mercury RTCOA 4.5.4.1 (iOS 12.1; en_US; iPhone)' -H 'Accept-Language: en-US;q=1, es-US;q=0.9' --data-binary "{\"t_heat\": $1}" --compressed 'https://my.radiothermostat.com/rtcoa/rest/gateways/5cdad455c026'
}

load_dotenv_vars() {
  set -o allexport; source .env; set +o allexport
}

# Run the Claude Code /standup command, showing a spinner while it works
# (claude -p buffers all output until it finishes, so without this the
# terminal just sits blank).
standup() {
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
