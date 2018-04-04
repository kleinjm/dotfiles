" make sure vim-plug is installed so plugins can be installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" after adding new plugins write, source, and run :PlugInstall
" highlight all and :sort to sort
call plug#begin('~/.vim/plugged') " Specify a directory for plugins

" Make sure you use single quotes
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim' " find or install fzf
Plug 'AndrewRadev/vim-eco'                          " .eco syntax highlighting
Plug 'airblade/vim-gitgutter'                       " show git changes in gutter
Plug 'calebsmith/vim-lambdify'                      " conceal js functions with lambda
Plug 'christoomey/vim-run-interactive'              " allow interactive shell
Plug 'christoomey/vim-tmux-navigator'               " allow ctrl+hjkl to navigate between vim and tmus
Plug 'christoomey/vim-tmux-runner'                  " allows sending commands to tmux from vim
Plug 'easymotion/vim-easymotion'                    " vim motions on speed
Plug 'henrik/vim-indexed-search'                    " display search count
Plug 'itchyny/lightline.vim'                        " vim status bar coloring
Plug 'jbgutierrez/vim-partial'                      " extract haml partials
Plug 'jgdavey/vim-blockle'                          " toggle ruby do and {} blocks
Plug 'jiangmiao/auto-pairs'                         " open and close brackets
Plug 'kana/vim-textobj-user'                        " dependency of nelstrom/vim-textobj-rubyblock
Plug 'kchmck/vim-coffee-script'                     " syntax for coffeescript
Plug 'maksimr/vim-jsbeautify'                       " format js and html pages
Plug 'mattn/emmet-vim'                              " html and css editing
Plug 'michaeljsmith/vim-indent-object'              " vii to highlight lines at same indent level
Plug 'nanotech/jellybeans.vim', { 'tag': 'v1.6' }   " color scheme
Plug 'nelstrom/vim-textobj-rubyblock'               " provide ruby text objects
Plug 'nelstrom/vim-visual-star-search'              " * to serach current word
Plug 'onemanstartup/vim-slim'                       " syntax for slim. Use this over the official slim-template/vim-slim plugin for way better speed. See https://github.com/slim-template/vim-slim/issues/19#issuecomment-50607474
Plug 'posva/vim-vue'                                " syntax highlighting for vueJS
Plug 'ryanoasis/vim-devicons'                       " font icon integration
Plug 'szw/vim-tags'                                 " generate tag files on save
Plug 'thoughtbot/vim-rspec'                         " allow tests running from vim
Plug 'tpope/vim-bundler'                            " support helpers for bundler
Plug 'tpope/vim-fugitive'                           " look in .git/ctags for ctags index
Plug 'tpope/vim-rails'                              " directory navigation and syntax for rails
Plug 'tpope/vim-rake'                               " configures path for lib and ext directories on ruby and rails projects
Plug 'tpope/vim-repeat'                             " allow . repeat on plugin commands
Plug 'tpope/vim-rhubarb'                            " :Gbrowse to get GH url
Plug 'tpope/vim-surround'                           " add paren and quote helpers
Plug 'tpope/vim-unimpaired'                         " handy bracket mappings
Plug 'vim-ruby/vim-ruby'                            " support for running ruby
Plug 'vim-scripts/tComment'                         " comment with `gc`
Plug 'w0rp/ale'                                     " async linter

call plug#end() " Initialize plugin system
