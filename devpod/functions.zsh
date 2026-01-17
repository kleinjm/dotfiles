# Git: delete local branches that don't exist on origin
gprune() {
  git fetch --prune
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# Git: pull latest and merge main
gupdate() {
  git pull && git pull origin main
}

# Load .env vars into shell
load_dotenv_vars() {
  set -o allexport; source .env; set +o allexport
}
