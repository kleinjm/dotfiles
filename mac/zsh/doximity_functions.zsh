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

# docker attach with the full name of the container with the given name
# ie. dox-attach doximity # => docker attach dox-compose_doximity_1_f8a98b0bfa9e
dox-attach() {
  [ "$#" -eq 1 ] || die "1 argument required, $# provided"

  docker ps | grep -o "dox-compose_$1_1\w*" | xargs docker attach
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

# rails db:migrate
ddrdm() {
  dox-do rails db:migrate
}

# grep routes
ddrrg() {
  dox-do rails routes | grep $0
}

# grep rake tasks
ddrT() {
  dox-do rake -T | grep $0
}

# bundle
ddbundle() {
  dox-do bundle install
}

# bash shell
ddsh() {
  dox-do bash
}

# rails console
ddrc() {
  dox-do rails console
}
