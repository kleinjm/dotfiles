# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.
# Don't forget that zsh plugins like git include their own aliases

# shell commands
alias ls="ls -FGhla" # -F symbols, -G colorized output, -h full unit (Kilobyte)

# Brew
# Remove pyenv configs as not to interfere with brew
# alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"

# Always use the latest installed ruby version for the latest tmuxinator version.
# A function (not an alias) so the version resolves at call time, after rbenv
# loads, and so an uninstalled `rbenv global` never gets baked in.
mux() {
  local version
  version=$(rbenv versions --bare 2>/dev/null | grep -E '^[0-9]+\.[0-9]+' | sort -V | tail -1)
  if [[ -n "$version" ]]; then
    RBENV_VERSION="$version" tmuxinator "$@"
  else
    tmuxinator "$@"
  fi
}
compdef mux=tmuxinator 2>/dev/null

# Slack-ready standup block from GitHub + the EscrowSafe project board
# (deterministic Ruby script — no Claude/LLM). See shared/scripts/standup.rb.
alias standup='ruby "$DOTFILES_DIR/shared/scripts/standup.rb"'
