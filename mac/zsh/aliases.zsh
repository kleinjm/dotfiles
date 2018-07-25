# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.
# Don't forget that zsh plugins like git include their own aliases

# shell commands
alias cp="cp -iv" # -i will ask form confirmation when overwriting files
alias df="df -h" # disk free space
alias du="du -cksh" # disk usage
alias ls="ls -FGhla" # -F symbols, -G colorized output, -h full unit (Kilobyte)
alias mv="mv -iv" # -i will ask confirmation before overwriting an existing dir
alias rm="rm -v" # -i will ask confirmation before deleting a file

# Use modern regexps for sed, ie. "(one|two)", not "\(one\|two\)"
alias sed="sed -E"

# When copy-pasting a command, $ will be ignored. Ie. "$ ruby my_file.rb"
alias \$=''

# Git
alias develop='git fetch --prune && git checkout develop && git pull origin develop'
alias ga='git add'
alias gl='git log'
alias gpod='git pull origin develop'
alias gpom='ggl && git pull origin master'
alias gs='git s'
alias master='git fetch --prune && git checkout master && git pull origin master'

# NodeJS, NPM
alias sequelize="node_modules/.bin/sequelize"

# Rails
alias rT="bundle exec rake -T | ag " # search rake tasks
alias rake='noglob rake' # https://github.com/robbyrussell/oh-my-zsh/issues/433#issuecomment-1670663
alias rc!="spring stop && rails console"
alias resolve-rails="master && bundle install && rails db:migrate && rails db:test:prepare"

# Misc, Personal
alias get-song="$DOTFILES_DIR/mac/scripts/get_song.sh"
alias pack="ruby $PROJECT_DIR/packing_checklist/app/run.rb"
alias passwords="$DOTFILES_DIR/mac/scripts/passwords.sh"
alias pomo="$DOTFILES_DIR/mac/scripts/vendor/pomodoro" # https://github.com/carlmjohnson/pomodoro
alias speed="speedtest-cli" # run a speedtest
alias upload-music="$DOTFILES_DIR/mac/scripts/upload_music.sh"
alias download-music="$DOTFILES_DIR/mac/scripts/download_music.sh"

# Doximity
alias dox="cd $PROJECT_DIR/doximity"
alias doxserver='bin/rails s webrick -p5000'
alias doxstart="$DOTFILES_DIR/tmuxinator/start_doximity.sh"
alias e2e-single="TEST_WEBDRIVER_TIMEOUT=99999999 SKIP_OAUTH=true ./node_modules/.bin/wdio --spec"

# Global aliases
alias -g G="| ag " # ie. "rails routes G user" vs "rails routes | ag user"
