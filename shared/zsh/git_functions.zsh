# delete local branches that do not exist on origin
gprune() {
  git fetch --prune &&
    git branch -r |
    awk '{print $1}' |
    egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) |
    awk '{print $1}' | xargs git branch -D
}

# pull the latest remote changes for this branch and merge latest remote master
gupdate() {
  ggl && git pull origin master
}

# Put a list of all the specs on the current branch into the copy buffer.
# Useful for testing a branch inside a docker container
gspec() {
  git diff origin/master --name-only | grep _spec | tr '\n' ' ' | sed -e 's/^/bin\/rspec /' | pbcopy
}
