die () {
  echo >&2 "$@"
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

ddup() {
  [ "$#" -eq 1 ] || die "1 argument required, $# provided"

  dox-dc up -d $1 && docker attach "dox-compose_$1_1"
}

# start doximity core apps, projects and services in tmux sessions
doxstart() {
  # a lot of apps rely on the docker container in doximity so keep it at top
  local apps=(dox-compose doximity activities doc-news dotfiles)

  for app in ${apps[@]}; do
    echo "Starting $app"
    tmuxinator start $app --no-attach
  done

  tmux attach -t doximity
}
