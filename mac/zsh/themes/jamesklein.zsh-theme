# Personal fork of robbyrussell

prompt_color()  { print "%{$fg[$2]%}$1%{$reset_color%}" }
prompt_green()  { prompt_color "$1" green }
prompt_magenta(){ prompt_color "$1" magenta }
prompt_purple() { prompt_color "$1" purple }
prompt_red()    { prompt_color "$1" red }
prompt_cyan()   { prompt_color "$1" cyan }
prompt_blue()   { prompt_color "$1" blue }
prompt_yellow() { prompt_color "$1" yellow }
prompt_spaced() { [[ -n "$1" ]] && print " $@" }

prompt_ruby_version() {
  local version=$(rbenv version-name)
  prompt_magenta "$version "
}

# I was doing this with nvm version but that's very slow. Having the nvmrc
# does not mean we're on that version, it's just the version the project
# wants to be using. May be worth caching if it becomes an issue
prompt_node_version() {
  local version=$(cat .nvmrc)
  prompt_magenta "$version "
}

prompt_language_version() {
  if [ -f "$PWD/.nvmrc" ]; then
    prompt_node_version
  elif [ -f "$PWD/.ruby-version" ]; then
    prompt_ruby_version
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status} $(prompt_language_version)%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
