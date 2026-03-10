# Git: delete local branches that don't exist on origin
gprune() {
  git fetch --prune
  local worktree_branches=$(git worktree list --porcelain 2>/dev/null | awk '/^branch / {sub(/^refs\/heads\//, "", $2); print $2}')
  git branch -vv | grep ': gone]' | awk '{gsub(/^[* +]+/, ""); print $1}' |
    grep -vxF "$worktree_branches" | xargs -r git branch -D
}

# Git: pull latest and merge main
gupdate() {
  git pull && git pull origin main
}

# Load .env vars into shell
load_dotenv_vars() {
  set -o allexport; source .env; set +o allexport
}
