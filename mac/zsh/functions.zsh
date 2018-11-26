die () {
    echo >&2 "$@"
    exit 1
}

# fd - cd to selected directory
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

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# delete local branches that do not exist on origin
gprune() {
  git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
}

# wait until the given docker container is up
# ie. wait_for_docker doximity # => ......doximity service started
wait_for_docker() {
  [ "$#" -eq 1 ] || die "1 argument required, $# provided"

  while ! { docker ps | grep -q dox-compose_$1_1 ; } ; do
      printf '.'
      sleep 1
  done

  echo $1 service started
}

# docker attach with the full name of the container with the given name
# ie. dox-attach doximity # => docker attach dox-compose_doximity_1_f8a98b0bfa9e
dox-attach() {
  [ "$#" -eq 1 ] || die "1 argument required, $# provided"

  docker ps | grep -o "dox-compose_$1_1\w*" | xargs docker attach
}

# start doximity core apps, projects and services in tmux sessions
doxstart() {
  # a lot of apps rely on the docker container in doximity so keep it at top
  apps=(dox-compose doximity activities doc-news dotfiles)

  for app in ${apps[@]}; do
    echo "Starting $app"
    tmuxinator start $app --no-attach
  done

  tmux attach -t doximity
}
