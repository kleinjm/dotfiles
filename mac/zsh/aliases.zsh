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
alias rm="rm -iv" # -i will ask confirmation before deleting a file

# Use modern regexps for sed, ie. "(one|two)", not "\(one\|two\)"
alias sed="sed -E"

# When copy-pasting a command, $ will be ignored. Ie. "$ ruby my_file.rb"
alias \$=''

# Git
alias gpom='git pull origin master'
alias gpod='git pull origin develop'
alias master='git fetch --prune && git checkout master && git pull origin master'
alias develop='git fetch --prune && git checkout develop && git pull origin develop'

# NodeJS, NPM
alias sequelize="node_modules/.bin/sequelize"

# Rails
alias resolve_rails="master && bundle install && rails db:migrate && rails db:test:prepare"

# Misc, Personal
alias passwords="~/Dropbox/passwords.sh"
alias speed="speedtest-cli" # run a speedtest
alias pack="ruby ~/GitHubRepos/packing_checklist/app/run.rb"
alias get-song="~/GitHubRepos/dotfiles/mac/scripts/get_song.sh"

# Doximity
alias dox='cd ~/GitHubRepos/doximity'
alias doxserver='bin/rails s webrick -p5000'
alias doxstart='~/GitHubRepos/dotfiles/tmuxinator/start_doximity.sh'
alias e2e-single="TEST_WEBDRIVER_TIMEOUT=99999999 SKIP_OAUTH=true ./node_modules/.bin/wdio --spec"

# Global aliases
alias -g G="| ag " # ie. "rails routes G user" vs "rails routes | ag user"
