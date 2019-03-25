die () {
  echo >&2 "$@"
  return 1
}

# start doximity core apps, projects and services in tmux sessions
doxstart() {
  # a lot of apps rely on the docker container in doximity so keep it at top
  local apps=(doximity doc-news)

  for app in ${apps[@]}; do
    echo "Starting $app"
    tmuxinator start $app --no-attach
  done

  tmux attach -t doximity
}

# wait until the given docker container is up
# ie. wait_for_docker # => ......doximity service started
wait_for_docker() {
  service=$(basename "$(git rev-parse --show-toplevel)")

  while ! { docker ps | grep -q dox-compose_${service}_1 ; } ; do
      printf '.'
      sleep 1
  done

  echo ${service} service started
}

# Starts the GIVEN service
# NOTE: Not using the repo name because this can be used
#   for workers and daemons as well
ddup() {
  [ "$#" -eq 1 ] || die "Please provide the name of the container, ie. doximity"

  dox-dc up -d $1 && docker attach "dox-compose_$1_1"
}

# start a rails console with pryrc files copied into the container
ddrc() {
  service=$(basename "$(git rev-parse --show-toplevel)")

  docker cp $DOTFILES_DIR/pry/. "dox-compose_${service}_1":/root

  dox-do rails console
}

# start a docker bash shell with select dotfiles copied over
# ddsh() {
#   service=$(basename "$(git rev-parse --show-toplevel)")
#
#   docker cp $DOTFILES_DIR/docker_debian/.zshrc "dox-compose_${service}_1":/root
#
#   dox-do bash
# }
