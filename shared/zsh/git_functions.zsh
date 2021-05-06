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

# Merge either the given branch name or current branch (if none given) to the
# staging environment. Pass -f to force push as needed.
push_staging() {
  current_branch=$(\
    git for-each-ref \
    --format='%(objectname) %(refname:short)' refs/heads \
    | awk "/^$(git rev-parse HEAD)/ {print \$2}"\
  )

  if [[ "$1" == "" ]]; then
    branch_to_push=$current_branch
  else
    branch_to_push="$1"
  fi

  git checkout deploy-staging
  git merge $branch_to_push

  if [[ "$1" == "-f" || "$2" == "-f" ]]; then
    git push origin deploy-staging -f
  else
    git push origin deploy-staging
  fi

  git checkout $current_branch
}
