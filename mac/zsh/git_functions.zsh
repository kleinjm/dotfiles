# delete local branches that do not exist on origin
gprune() {
  git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
}

# pull the latest remote changes for this branch and merge latest remote master
gupdate() {
  ggl && git pull origin master
}
