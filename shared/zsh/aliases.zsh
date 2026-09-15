# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.
# Don't forget that zsh plugins like git include their own aliases

# shell commands
alias ls="ls -FGhla" # -F symbols, -G colorized output, -h full unit (Kilobyte)

# Brew
# Remove pyenv configs as not to interfere with brew
# alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"

# Never set RBENV_VERSION here: tmuxinator starts the tmux server, so anything
# exported leaks into every pane of the session. The rbenv global (written to
# the latest installed ruby by symlink_to_dotfiles_repo.sh) is enough.
alias mux=tmuxinator

# Slack-ready standup block from GitHub + the EscrowSafe project board
# (deterministic Ruby script — no Claude/LLM). See shared/scripts/standup.rb.
alias standup='ruby "$DOTFILES_DIR/shared/scripts/standup.rb"'
