# Sourced from ~/.zshrc in the locky container by locky/setup.local.sh.

# gh with the classic public_repo token, for issues and PRs on repos outside
# EscrowSafe. Plain gh keeps the EscrowSafe token from web/.env.
ghpub() {
  GH_TOKEN="$(cat /workspace/docker-data/gh-public-token)" gh "$@"
}
