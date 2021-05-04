# delete local branches that do not exist on origin
gprune() {
  git prune &&
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

# Merge current branch to staging env
push_staging() {
  branch=$(\
    git for-each-ref \
    --format='%(objectname) %(refname:short)' refs/heads \
    | awk "/^$(git rev-parse HEAD)/ {print \$2}"\
  )

  git checkout deploy-staging
  git merge $branch
  git push origin deploy-staging
}
