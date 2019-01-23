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

# run this before the broken dox-compose bootstrap script to get the repos
dox_clone_repos() {
  git clone https://github.com/doximity/activities && git clone https://github.com/doximity/amion-api && git clone https://github.com/doximity/amion-sync && git clone https://github.com/doximity/apn && git clone https://github.com/doximity/auth-api && git clone https://github.com/doximity/bridge-schema && git clone https://github.com/doximity/campaigns && git clone https://github.com/doximity/career-match && git clone https://github.com/doximity/colleague-connect && git clone https://github.com/doximity/colleagues && git clone https://github.com/doximity/dialer-api && git clone https://github.com/doximity/directory && git clone https://github.com/doximity/doc-news && git clone https://github.com/doximity/doc-news-public && git clone https://github.com/doximity/docnav && git clone https://github.com/doximity/dox-dut-service && git clone https://github.com/doximity/doximity && git clone https://github.com/doximity/doximity-client-vue && git clone https://github.com/doximity/email-delivery && git clone https://github.com/doximity/finder && git clone https://github.com/doximity/foundation && git clone https://github.com/doximity/job-listings && git clone https://github.com/doximity/opmed && git clone https://github.com/doximity/push-notification-api && git clone https://github.com/doximity/blog-engine && git clone https://github.com/doximity/residency && git clone https://github.com/doximity/spectrum && git clone https://github.com/doximity/unipub
}
