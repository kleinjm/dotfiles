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

# Diffity: review the current branch against the local `main` branch in the
# browser, using the colorblind-safe palette. Runs against whatever repo the
# current directory belongs to. The server binds :5391 (exposed by the web
# devcontainer's compose.override.yaml) and prints a URL to open on the host.
# Extra args pass through, e.g. `review-changes --dark` or `review-changes --new`.
review-changes() {
  diffity --colorblind --no-open --port 5391 --base main "$@"
}

# Load .env vars into shell
load_dotenv_vars() {
  set -o allexport; source .env; set +o allexport
}
