#!/bin/sh
# Claude Code status line — mirrors the jamesklein oh-my-zsh theme
# Shows: current dir | git branch + dirty/clean | model

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Current directory basename (like %c in zsh theme)
dir=$(basename "$cwd")

# Git info (skip locks to avoid blocking)
git_branch=""
git_status_marker=""
if git_branch_raw=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null); then
  git_branch="$git_branch_raw"
  if git -C "$cwd" status --porcelain 2>/dev/null | grep -q .; then
    git_status_marker=" ✗"
  else
    git_status_marker=" ✓"
  fi
fi

# ANSI colors
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD_BLUE='\033[1;34m'
DIM='\033[2m'
RESET='\033[0m'

# Build the status line
if [ -n "$git_branch" ]; then
  printf "${CYAN}%s${RESET} ${BOLD_BLUE}${RED}%s${YELLOW}%s${RESET}  ${DIM}%s${RESET}" \
    "$dir" "$git_branch" "$git_status_marker" "$model"
else
  printf "${CYAN}%s${RESET}  ${DIM}%s${RESET}" "$dir" "$model"
fi
