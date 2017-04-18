
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2015 Mar 24
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

let mapleader=" "

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set undofile		" keep an undo file (undo changes after closing)
set nobackup 		" do not keep a backup. Set originally for the unandpw.txt file
set nowritebackup	" change the write behavior to leave no trailing files

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set number              " display line numbers
set relativenumber  " set relative line numbering
set numberwidth=5   " give some space between relative and static line numbers
" search case insensitive, until first capital used
set ignorecase smartcase
set scrolloff=5 " prevent hitting the bottom of the screen
" check the current folder for tags file and keep going one directory up all
" the way to the root folder
set tags=tags;/
" highlight line and column
set cursorline
set cursorcolumn
" copy to the system clipboard
set clipboard=unnamed

runtime macros/matchit.vim

" map Enter to insert a new line without entering insert mode
map <CR> o<Esc>

" ctrl+space exits out of search and everything
nnoremap <C-@> <Esc>:noh<CR>
vnoremap <C-@> <Esc>gV
onoremap <C-@> <Esc>
cnoremap <C-@> <C-c>
inoremap <C-@> <Esc>

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") |
          \   exe "normal! g`\"" |
          \ endif

  augroup END

  " trim trailing whitespace on save
  autocmd BufWritePre * %s/\s\+$//e
else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

" set tab size to 2
set tabstop=2
" use spaces for indenting with '>'
set shiftwidth=2
" set spaces for tab
set expandtab

nnoremap <C-n> :call NumberToggle()<cr>

" highlight lines over 80 chars
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" Rename current file
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <Leader>n :call RenameFile()<cr>

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  let g:ackprg = 'ag --nogroup --nocolor --column'

  if !exists(":Ack")
    command -nargs=+ -complete=file -bar Ack silent! grep! <args>|cwindow|redraw!

    " use \ to search
    nnoremap \ :Ack<SPACE>

    " bind K to grep word under cursor
    nnoremap K :Ack "\b<C-R><C-W>\b"<CR>:cw<CR>
  endif
endif

" Zoom / Restore window.
function! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-A> :ZoomToggle<CR>

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

function! DeleteFile(...)
  if(exists('a:1'))
    let theFile=a:1
  elseif ( &ft == 'help' )
    echohl Error
    echo "Cannot delete a help buffer!"
    echohl None
    return -1
  else
    let theFile=expand('%:p')
  endif
  let delStatus=delete(theFile)
  if(delStatus == 0)
    echo "Deleted " . theFile
  else
    echohl WarningMsg
    echo "Failed to delete " . theFile
    echohl None
  endif
  return delStatus
endfunction
"delete the current file
com! Rm call DeleteFile()
"delete the file and quit the buffer (quits vim if this was the last file)
com! RM call DeleteFile() <Bar> q!

" set status line to show file name
:set statusline=%f\ -\ FileType:\ %y

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'thoughtbot/vim-rspec'
Plug 'vim-ruby/vim-ruby'
Plug 'https://github.com/christoomey/vim-tmux-runner.git'
Plug 'slim-template/vim-slim'
Plug 'kchmck/vim-coffee-script'
Plug 'kana/vim-textobj-user' " dependency of nelstrom/vim-textobj-rubyblock
Plug 'nelstrom/vim-textobj-rubyblock' " provide ruby text objects
Plug 'airblade/vim-gitgutter' " show git changes in gutter
Plug 'tpope/vim-rails' " directory navigation and syntax for rails
Plug 'tpope/vim-bundler'
Plug 'nelstrom/vim-visual-star-search' " * to serach current word
Plug 'nanotech/jellybeans.vim', { 'tag': 'v1.6' } " color scheme
Plug 'vim-scripts/tComment' " comment with `gc`
Plug 'mileszs/ack.vim' " backbone for silver searcher
Plug 'scrooloose/syntastic' " display errors such as rubocop

" Initialize plugin system
call plug#end()
" Remember to :w, :so ~/.vimrc and run :PlugInstall after adding new plugins

" set color scheme
colorscheme jellybeans

" RSpec.vim mappings
let g:rspec_command = "VtrSendCommand! bin/rspec {spec}"
let g:rspec_runner = "os_x_iterm"
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

" leader + i inserts binding.pry
map <Leader>i obinding.pry<ESC>
" reindent the entire file
map <leader>= mzgg=G`z

" fzf fuzzy find
nnoremap <leader>f :Files<cr>
nnoremap <leader>dc :Files app/controllers<cr>
nnoremap <leader>dm :Files app/models<cr>
nnoremap <leader>dv :Files app/views<cr>
nnoremap <leader>ds :Files spec/<cr>

" Don't use arrow keys
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Syntastic config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_ruby_checkers = ['rubocop']
