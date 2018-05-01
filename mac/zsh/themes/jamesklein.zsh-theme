# Personal fork of robbyrussell

# TODO: It would be cool to have this show the nvm node version in a JS project
prompt_color()  { print "%{$fg[$2]%}$1%{$reset_color%}" }
prompt_magenta(){ prompt_color "$1" magenta }

prompt_ruby_version() {
  local version=$(rbenv version-name)
  prompt_magenta "$version"
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status} $(prompt_ruby_version) %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
