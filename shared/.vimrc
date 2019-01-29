"==============================================================================
" File: vimrc
" Author: James Klein [http://www.jamesmklein.com]
"==============================================================================

" Set python version to 3. To set to python 2, simply `has('python')` instead.
" If this in not set, the first thing that calls python will set the version
" and it then cannot be switched. See
" https://robertbasic.com/blog/force-python-version-in-vim/
if has('python3')
  silent! python3 1
endif

source ~/.vim/functions.vim " define functions to map to
source ~/.vim/lightline.vim " configure lightline and status bar
source ~/.vim/plugins.vim " load vim-plug and plugins

let mapleader=" "                     " set leader key to space
colorscheme jellybeans                " set color scheme

set autoindent		             " autoindenting on
set autoread                   " auto-reload the current file when switching to it
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set cmdheight=1                " lines in the command bar
set complete-=i                " do not scan included files such as all ruby gems. Faster tab completion
set encoding=utf8              " set to show fonts and glyphs
set expandtab                  " set spaces for tab
set grepprg=ag                 " use ag for grepping
set guifont=FuraMono\ Nerd\ Font\ Regular:h12 lsp=2
set hidden                     " Allow buffer change w/o saving
set history=1000		           " keep 1000 lines of command line history
set hlsearch                   " highlight the last used search pattern
set ignorecase smartcase       " search case insensitive, until first capital used
set incsearch		               " highlight matches while searching
set laststatus=2               " always display the statusbar for lightline
set lazyredraw                 " Don't update while executing macros
set nobackup 		               " do not keep a backup file. Set for unandpw.txt
set nocompatible               " Use Vim settings, rather than Vi settings. Needed for vim-textobj-rubyblock plugin
set noswapfile                 " Turn off swap (.swp) files
set noundofile                 " Turn off undo (.un~) files
set nowritebackup	             " don't make backup when overwriting file
set number                     " display line numbers
set numberwidth=5              " give space between relative and static line numbers
set re=1                       " use old regex engine to speed up ruby syntax hightlighting
set ruler		                   " show the cursor position all the time
set scrolloff=5                " prevent hitting the bottom of the screen
set shell=/bin/zsh             " set vi internal shell to zsh
set shiftwidth=2               " use spaces for indenting with '>'
set showcmd		                 " display incomplete commands
set synmaxcol=256              " stop syntax highlighting on long lines
set tabstop=2                  " set tab size to 2
set tags=tags;/                " check the current folder for tags file and keep going up
set undofile		               " keep an undo file (undo changes after closing)
set updatetime=1000            " slow update for linting
set wildmode=list:longest,list:full " used for smart tab completion

let g:grep_cmd_opts = '--line-numbers --noheading'

" enable mouse mode
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has("gui_running")
  syntax on
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

" Always show an extra column on the left for gitgutter
if exists('&signcolumn')  " Vim 7.4.2201
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif

runtime macros/matchit.vim " use % to switch between if/else/end

" auto indent and format json and xml
nnoremap =j :call FormatJSON()<cr>
nnoremap =x :%!XMLLINT_INDENT='    ' xmllint --format %<cr>
nnoremap <silent>K :call FindWordUnderCursor()<cr>

" hit s while highlighting to sort a list
vnoremap s :!sort<cr>

" map Enter to insert a new line without entering insert mode
map <CR> o<Esc>
" Don't use Ex mode, use Q for formatting
map Q gq
" map 0 to go to first char on line
nmap 0 ^
" Move up and down by visible lines if current line is wrapped
" NOTE: this messes with with jumping up and down relative line numbers
nmap j gj
nmap k gk

" save
inoremap <C-p> <esc>:w<cr>
noremap <C-p> <esc>:w<cr>

" ctrl+space exits out of search and everything
nnoremap <C-@> <Esc>:noh<CR>
vnoremap <C-@> <Esc>gV
onoremap <C-@> <Esc>
cnoremap <C-@> <C-c>
inoremap <C-@> <Esc>

" Don't use arrow keys
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" Zoom / Restore window
" NOTE: not sure why this didn't work in functions.vim
fun! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfun

" Zoom / Restore window with <ctrl>+a
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-A> :ZoomToggle<CR>

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  source ~/.vim/autocommands.vim " load autocommand settings if available
endif

" ##### EasyMotion Config #####
let g:EasyMotion_do_mapping = 0 " Disable default mappings
let g:EasyMotion_smartcase = 1  " Turn on case insensitive feature

" Jump to anywhere with `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)

" give a choice to which char to perform a verb on if there is more than one
" on that line. ie. dfn = delete find 'n' and will highlight all n's
omap f <plug>(easymotion-bd-fl)
omap F <plug>(easymotion-Fl)
omap t <plug>(easymotion-bd-tl)
omap T <plug>(easymotion-Tl)
" verb to a full line such as `dl` to delete to line
omap l <plug>(easymotion-bd-jk)

" applies a verb to the motion with a 1 char search. ie. `dmt` will delete
" until the selected 't'
map m <plug>(easymotion-s)
vmap m <plug>(easymotion-s)
" ##### END EasyMotion Config #####


" ##### ALE async linting config #####

" Linting on all changes felt too aggressive. The below settings calls lint on
" certain events, either when I stop interacting or when entering / leaving
" insert mode


let g:ale_lint_delay = 1000
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 0
" disable ale highlighting on errors (still get the column indicator)
let g:ale_set_highlights = 0
" ##### END ALE async linting config #####


" ##### RSpec.vim mappings #####
let g:rspec_command = "VtrSendCommand! bin/rspec {spec}"
let g:rspec_runner = "os_x_iterm"
let g:VtrClearSequence=" "
" ##### END RSpec.vim mappings #####


" ##### AG & FZF #####
" Use ag (The Silver Searcher) https://github.com/ggreer/the_silver_searcher
if executable("ag")
  let g:ackprg = 'ag --vimgrep'
  nnoremap \ :Ag!<SPACE>
endif

" Augmenting Ag command using fzf#vim#with_preview function
"   * fzf#vim#with_preview([[options], preview window, [toggle keys...]])
"     * For syntax-highlighting, Ruby and any of the following tools are required:
"       - Highlight: http://www.andre-simon.de/doku/highlight/en/highlight.php
"       - CodeRay: http://coderay.rubychan.de/
"       - Rouge: https://github.com/jneen/rouge
"
"   :Ag  - Start fzf with hidden preview window that can be enabled with "?" key
"   :Ag! - Start fzf in fullscreen and display the preview window above
command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  \                 <bang>0)

" Search only the files that are on the current and uncommitted branch
command! Fzfc call fzf#run(fzf#wrap({'source': 'git diff origin/master --name-only'}))

let g:fzf_files_options =
      \ '--reverse ' .
      \ '--preview "(coderay {} || cat {}) 2> /dev/null | head -'.&lines.'"'
" ##### END AG & FZF #####

" ##### UltiSnips #####
" let g:UltiSnipsExpandTrigger="<c-j>"
" let g:UltiSnipsListSnippets="<c-k>"
" let g:UltiSnipsJumpForwardTrigger="<c-l>"
" let g:UltiSnipsJumpBackwardTrigger="<c-h>"
" let g:UltiSnipsSnippetsDir='~/.vim/UltiSnips'
"
" " If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"
" ##### END UltiSnips #####

" Source these last because they depend on the other definitions
source ~/.vim/leader_mappings.vim " define leader key mappings
