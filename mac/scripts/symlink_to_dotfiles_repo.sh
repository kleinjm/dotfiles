#!/bin/bash

set -e
set -o pipefail

# v = verbose, t = target directory, d = current directory

stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d mac git
stow -v -t "$HOME" -d mac redis
stow -v -t "$HOME" -d mac gnupg

stow -v -t "$HOME" nvm
stow -v -t "$HOME" pry
stow -v -t "$HOME" psql
stow -v -t "$HOME" -d shared ag
stow -v -t "$HOME" -d shared tmux
stow -v -t "$HOME" -d mac tmux

stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d mac vim

mkdir -p "$HOME"/.config/nvim
stow -v -t "$HOME"/.config/nvim -d mac nvim

# may need to `rm $HOME/.zshrc`
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d mac zsh --ignore='.profile'

ln -sf "$DOTFILES_DIR"/mac/scripts/vendor/* /usr/local/bin

mkdir -p "$HOME"/.pyenv
ln -sf "$DOTFILES_DIR"/shared/pyenv/version "$HOME"/.pyenv/version

# Don't check the global ruby version into the repo: a literal version string
# breaks on any machine that hasn't installed it. Point the global at the
# latest installed ruby instead; project .ruby-version files still win.
mkdir -p "$HOME"/.rbenv
rm -f "$HOME"/.rbenv/version
latest_ruby=$(rbenv versions --bare 2>/dev/null | grep -E '^[0-9]+\.[0-9]+' | sort -V | tail -1)
if [ -n "$latest_ruby" ]; then
  echo "$latest_ruby" > "$HOME"/.rbenv/version
fi

# Cursor IDE settings
mkdir -p "$HOME"/Library/Application\ Support/Cursor/User
ln -sf "$DOTFILES_DIR"/mac/cursor/keybindings.json "$HOME"/Library/Application\ Support/Cursor/User/keybindings.json
ln -sf "$DOTFILES_DIR"/mac/cursor/settings.json "$HOME"/Library/Application\ Support/Cursor/User/settings.json

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

# Symlink entire agent-os and claude directories
# If directory exists, do not symlink
ln -s "$DOTFILES_DIR"/mac/.agent-os "$HOME"
ln -s "$DOTFILES_DIR"/shared/.claude "$HOME"

# Per-project CLAUDE.local.md files, named <project>.CLAUDE.local.md. The link
# is relative so it resolves both here and inside a devcontainer, where the
# projects live under a different absolute path.
for local_md in "$DOTFILES_DIR"/shared/.claude/project-local/*.CLAUDE.local.md; do
  [ -e "$local_md" ] || continue
  project=$(basename "$local_md" .CLAUDE.local.md)
  if [ -d "$PROJECT_DIR/$project" ]; then
    ln -sfn "../dotfiles/shared/.claude/project-local/$(basename "$local_md")" \
      "$PROJECT_DIR/$project/CLAUDE.local.md"
  else
    echo "Skipping $project CLAUDE.local.md: $PROJECT_DIR/$project not found"
  fi
done

echo "Symlinking completed successfully"
