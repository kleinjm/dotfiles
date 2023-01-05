# Set personal aliases for any shell session
#
# NOTE: In an interactive shell, these are loaded before oh-my-zsh is sourced.
# Thus some of them may be overridden by oh-my-zsh such as `ls`
# https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/theme-and-appearance.zsh#L24
# See https://github.com/robbyrussell/oh-my-zsh/issues/5783#issuecomment-275614664
# Therefore, some aliases are also defined in aliases.zsh
#
# For a full list of active aliases, run `alias`.
# Don't forget that zsh plugins like git include their own aliases

# shell commands
alias cp="cp -iv" # -i will ask form confirmation when overwriting files
alias df="df -h" # disk free space
alias du="du -cksh" # disk usage
alias ls="ls -FGhla" # -F symbols, -G colorized output, -h full unit (Kilobyte)
alias mkdir="mkdir -v" # -v verobse
alias mv="mv -iv" # -i will ask confirmation before overwriting an existing dir
alias rm="rm -v" # -i will ask confirmation before deleting a file

# Use modern regexps for sed, ie. "(one|two)", not "\(one\|two\)"
alias sed="sed -E"

# When copy-pasting a command, $ will be ignored. Ie. "$ ruby my_file.rb"
alias \$=''

alias -g G="| ag " # ie. "rails routes G user" vs "rails routes | ag user"
alias ag="ag --path-to-ignore ~/.ag_ignore"

# Git
alias ga='git add'
alias gl='git log'
alias gs='git s'
alias main='git main'

# Vim
alias projections="cp $DOTFILES_DIR/projections.json .projections.json"

# Rails
alias rT="bundle exec rake -T | grep " # search rake tasks
alias rake='noglob rake' # https://github.com/robbyrussell/oh-my-zsh/issues/433#issuecomment-1670663
alias rc!="spring stop && rails console"
alias update="main && gprune && bundle && yarn && rails db:migrate && rails restart"

# Script shortcuts
alias print-cmd="$DOTFILES_DIR/mac/scripts/print-cmd.sh"
alias speed="speedtest" # run a speedtest
alias symlink="$DOTFILES_DIR/mac/scripts/symlink_to_dotfiles_repo.sh"
