# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
DEFAULT_USER=`whoami`
export ZSH=/Users/$DEFAULT_USER/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler osx rake ruby tmux docker zsh-autosuggestions zsh-syntax-highlighting)

# QT added to path to fix gem install capybara-webkit issue
export PATH=~/Qt5.5.1/5.5/clang_64/bin:~/.rbenv/shims:/usr/local/bin:/usr/bin:$PATH

# NOTE: PATH must be before this
source $ZSH/oh-my-zsh.sh

# tmuxinator autocomplete - allows `mux` in CLI
source ~/GitHubRepos/dotfiles/tmuxinator/tmuxinator.zsh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export MYVIMRC='~/.vimrc'

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias gpom='git pull origin master'
alias master='git fetch --prune && git checkout master && git pull origin master'
alias passwords="~/Dropbox/passwords.sh"
alias tmuxconf="vim ~/.tmux.conf"
alias vimconf="vim ~/.vimrc"
alias zshconf="vim ~/.zshrc"
alias speed="speedtest-cli" # run a speedtest

#  Doximity
alias dox='cd ~/GitHubRepos/doximity'
# export BULLET='true'
alias doxserver='bin/rails s webrick -p5000'
alias doxstart='~/GitHubRepos/dotfiles/tmuxinator/start_doximity.sh'
alias sshprod='ssh prod-doximity-console-1.dox.box'
alias e2e-single="TEST_WEBDRIVER_TIMEOUT=99999999 SKIP_OAUTH=true ./node_modules/.bin/wdio --spec"

export FAIL_SLOW=false
export RESIDENCY_URL='http://localhost:5120/'

eval $(thefuck --alias)
# https://github.com/rbenv/rbenv/issues/142
eval "$(rbenv init -)"
