"===========================================================================
" Author: James Klein [http://www.jamesmklein.com]
"===========================================================================

" after adding new plugins write, source, and run :PlugInstall
" highlight all and :sort to sort
call plug#begin('~/.vim/plugged') " Specify a directory for plugins

" Make sure you use single quotes
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim' " find or install fzf
Plug 'airblade/vim-gitgutter'                       " show git changes in gutter
Plug 'christoomey/vim-run-interactive'              " allow interactive shell
Plug 'christoomey/vim-tmux-navigator'               " allow ctrl+hjkl to navigate between vim and tmus
Plug 'christoomey/vim-tmux-runner'                  " allows sending commands to tmux from vim
Plug 'kana/vim-textobj-user'                        " dependency of nelstrom/vim-textobj-rubyblock
Plug 'kchmck/vim-coffee-script'                     " syntax for coffeescript
Plug 'nanotech/jellybeans.vim', { 'tag': 'v1.6' }   " color scheme
Plug 'nelstrom/vim-textobj-rubyblock'               " provide ruby text objects
Plug 'nelstrom/vim-visual-star-search'              " * to serach current word
Plug 'slim-template/vim-slim'                       " syntax for slim
Plug 'thoughtbot/vim-rspec'                         " allow tests running from vim
Plug 'tpope/vim-bundler'                            " support helpers for bundler
Plug 'tpope/vim-fugitive'                           " git interactions
Plug 'tpope/vim-rails'                              " directory navigation and syntax for rails
Plug 'tpope/vim-repeat'                             " allow . repeat on plugin commands
Plug 'tpope/vim-rhubarb'                            " :Gbrowse to get GH url
Plug 'tpope/vim-surround'                           " add paren and quote helpers
Plug 'vim-ruby/vim-ruby'                            " support for running ruby
Plug 'vim-scripts/tComment'                         " comment with `gc`
Plug 'w0rp/ale'                                     " async linter
Plug 'henrik/vim-indexed-search'                    " display search count

call plug#end() " Initialize plugin system

let mapleader=" "                     " set leader key to space
:set statusline=%f\ -\ FileType:\ %y\ -\ %l\:%c " set status line to show file name
colorscheme jellybeans                " set color scheme

" This must be first, because it changes other options as a side effect.
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set clipboard=unnamed          " copy to the system clipboard
set cursorcolumn               " highlight cursor column
set cursorline                 " highlight cursor line
set expandtab                  " set spaces for tab
set hidden                     " Allow buffer change w/o saving
set history=1000		           " keep 1000 lines of command line history
set ignorecase smartcase       " search case insensitive, until first capital used
set incsearch		               " do incremental searching
set lazyredraw                 " Don't update while executing macros
set nobackup 		               " do not keep a backup file. Set for unandpw.txt
set nocompatible               " Use Vim settings, rather than Vi settings
set nowritebackup	             " don't make backup when overwriting file
set number                     " display line numbers
set numberwidth=5              " give space between relative and static line numbers
set relativenumber             " set relative line numbering
set ruler		                   " show the cursor position all the time
set scrolloff=5                " prevent hitting the bottom of the screen
set shiftwidth=2               " use spaces for indenting with '>'
set showcmd		                 " display incomplete commands
set tabstop=2                  " set tab size to 2
set tags=tags;/                " check the current folder for tags file and keep going up
set undofile		               " keep an undo file (undo changes after closing)

runtime macros/matchit.vim " use % to switch between if/else/end

" map Enter to insert a new line without entering insert mode
map <CR> o<Esc>
" Don't use Ex mode, use Q for formatting
map Q gq
" leader + i inserts binding.pry
map <Leader>i obinding.pry<ESC>
" reindent the entire file
map <leader>= mzgg=G`z

" map 0 to go to first char on line
nmap 0 ^
" reload vimrc with leader+so
nmap <leader>so :source $MYVIMRC<cr>
" Split edit your vimrc. Type space, v, r in sequence to trigger
nmap <leader>vr :tabe $MYVIMRC<cr>
" Pre-populate a split command with the current directory
nmap <leader>v :vnew <C-r>=escape(expand("%:p:h"), ' ') . '/'<cr>
" Move up and down by visible lines if current line is wrapped
nmap j gj
nmap k gk
" Edit the db/schema.rb Rails file in a split
nmap <leader>sc :split db/schema.rb<cr>

" ctrl+a save and write in insert mode
imap <C-a> <esc>:w<cr>
" save in normal mode
map <leader>w <esc>:w<cr>
" Switch between the last two files
nnoremap <leader><leader> <c-^>

" ctrl+space exits out of search and everything
nnoremap <C-@> <Esc>:noh<CR>
vnoremap <C-@> <Esc>gV
onoremap <C-@> <Esc>
cnoremap <C-@> <C-c>
inoremap <C-@> <Esc>

" RSpec.vim mappings
let g:rspec_command = "VtrSendCommand! bin/rspec {spec}"
let g:rspec_runner = "os_x_iterm"
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

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

" enable mouse
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
  " Bind `q` to close the buffer for help files
  autocmd Filetype help nnoremap <buffer> q :q<CR>
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

" Prevent that the langmap option applies to characters that result from a
" mapping.  If unset (default), this may break plugins (but it's backward
" compatible).
if has('langmap') && exists('+langnoremap')
  set langnoremap
endif

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

  " Use ag in CtrlP for listing files. Lightning fast and respects
  " .gitignore
  let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

" ALE async linting
let g:ale_linters = {
      \ 'javascript': ['eslint']
      \ }

nmap <silent> [r <Plug>(ale_previous_wrap)
nmap <silent> ]r <Plug>(ale_next_wrap)

" Linting on all changes felt too aggressive. The below settings calls lint on
" certain events, either when I stop interacting or when entering / leaving
" insert mode
set updatetime=1000
autocmd CursorHold * call ale#Lint()
autocmd CursorHoldI * call ale#Lint()
autocmd InsertLeave * call ale#Lint()
autocmd TextChanged * call ale#Lint()
let g:ale_lint_on_text_changed = 0

" Zoom / Restore window with <ctrl>+a
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

" Delete the current file
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

