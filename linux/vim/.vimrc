" Vim configurations specific to linux

set clipboard=unnamedplus          " copy to the system clipboard

" gnome terminal color support
if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

source $DOTFILES_DIR/shared/.vimrc
