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
alias develop='git develop'
alias ga='git add'
alias gl='git log'
alias gpom='git pull origin master'
alias grom='git pull origin master --rebase'
alias gs='git s'
alias master='git master'

# Vim
alias projections="cp $DOTFILES_DIR/projections.json .projections.json"

# NodeJS, NPM
alias sequelize="node_modules/.bin/sequelize"

# Rails
alias mini="rails test" # minitest
alias rT="bundle exec rake -T | grep " # search rake tasks
alias rake='noglob rake' # https://github.com/robbyrussell/oh-my-zsh/issues/433#issuecomment-1670663
alias rc!="spring stop && rails console"
alias resolve-rails="master && bundle install && rails db:migrate && rails db:test:prepare"
alias resolve-vue="nvm use && master && yarn install"

# Script shortcuts
alias dependencies="$DOTFILES_DIR/mac/scripts/dependencies.sh"
alias download-music="$DOTFILES_DIR/mac/scripts/download_music.sh"
alias fixmouse="$DOTFILES_DIR/linux/scripts/fixmouse.sh"
alias get-song="$DOTFILES_DIR/mac/scripts/get_song.sh"
alias pack="ruby $PROJECT_DIR/packing_checklist/app/run.rb"
alias passwords="$DOTFILES_DIR/mac/scripts/passwords.sh"
alias print-cmd="$DOTFILES_DIR/mac/scripts/print-cmd.sh"
alias speed="speedtest-cli" # run a speedtest
alias symlink="$DOTFILES_DIR/mac/scripts/symlink_to_dotfiles_repo.sh"
alias upload-music="$DOTFILES_DIR/mac/scripts/upload_music.sh"

# Convox
## Swtich envs
alias prod="convox switch trim-prod-org/convoxprod"
alias staging="convox switch trim-prod-org/dev"
alias exp_prod="convox switch trim-prod-org/experian"
alias exp_staging="convox switch trim-prod-org/exp-staging"

## Rails console
alias prod_console="convox switch trim-prod-org/convoxprod && convox run web bundle exec rails console"
alias staging_console="convox switch trim-prod-org/dev && convox run web bundle exec rails console"
alias exp_prod_console="convox switch trim-prod-org/experian && convox run web bundle exec rails console"
alias exp_staging_console="convox switch trim-prod-org/experian-staging && convox run web bundle exec rails console"
alias go_upgrades_console="convox switch trim-prod-org/dev && convox run -a trim-app-upgrades web bundle exec rails console"

## Bash
alias prod_bash="convox switch trim-prod-org/convoxprod && convox run web bash"
alias staging_bash="convox switch trim-prod-org/dev && convox run web bash"
alias exp_prod_bash="convox switch trim-prod-org/experian && convox run web bash"
alias exp_staging_bash="convox switch trim-prod-org/experian-staging && convox run web bash"
alias go_upgrades_bash="convox switch trim-prod-org/dev && convox run -a trim-app-upgrades web bash"
