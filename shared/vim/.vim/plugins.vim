set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Keep Plugin commands between vundle#begin/end.
" Don't forget to source the .vimrc file before running :PluginInstall

" Plugin 'SirVer/ultisnips'                           " ultimate snippet solution for Vim
Plugin 'AndrewRadev/vim-eco'                          " .eco syntax highlighting
Plugin 'AoLab/vim-avro'                               " sytnax highlighting for avro schemas
Plugin 'calebsmith/vim-lambdify'                      " conceal js functions with lambda
Plugin 'christoomey/vim-run-interactive'              " allow interactive shell
Plugin 'christoomey/vim-tmux-navigator'               " allow ctrl+hjkl to navigate between vim and tmux
Plugin 'christoomey/vim-tmux-runner'                  " allows sending commands to tmux from vim
Plugin 'crusoexia/vim-javascript-lib'                 " syntax highlighting for common JS libraries
Plugin 'easymotion/vim-easymotion'                    " vim motions on speed
Plugin 'elixir-editors/vim-elixir'                      " elixir support
Plugin 'hashivim/vim-terraform'                       " terraform syntax and :Terraform command
Plugin 'henrik/vim-indexed-search'                    " display search count
Plugin 'honza/vim-snippets'                           " snippets
Plugin 'itchyny/lightline.vim'                        " vim status bar coloring
Plugin 'jbgutierrez/vim-partial'                      " extract haml partials
Plugin 'jgdavey/vim-blockle'                          " toggle ruby do and {} blocks
Plugin 'jiangmiao/auto-pairs'                         " open and close brackets
Plugin 'joker1007/vim-ruby-heredoc-syntax'            " heredoc ruby highlighing
Plugin 'junegunn/fzf.vim'                             " fzf vim integration
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } } " set fzf executable in the vim runtime path
Plugin 'kana/vim-textobj-user'                        " dependency of nelstrom/vim-textobj-rubyblock
Plugin 'kchmck/vim-coffee-script'                     " syntax for coffeescript
Plugin 'leafgarland/typescript-vim'                   " Typescript support for vim
Plugin 'maksimr/vim-jsbeautify'                       " format js and html pages
Plugin 'mattn/emmet-vim'                              " html and css editing
Plugin 'maximbaz/lightline-ale'                       " ale indicator for lightline
Plugin 'mhinz/vim-startify'                           " fancy startup screen
Plugin 'michaeljsmith/vim-indent-object'              " vii to highlight lines at same indent level
Plugin 'nanotech/jellybeans.vim', { 'tag': 'v1.6' }   " color scheme
Plugin 'nelstrom/vim-textobj-rubyblock'               " provide ruby text objects
Plugin 'nelstrom/vim-visual-star-search'              " * to serach current word
Plugin 'onemanstartup/vim-slim'                       " syntax for slim. Use this over the official slim-template/vim-slim plugin for way better speed. See https://github.com/slim-template/vim-slim/issues/19#issuecomment-50607474
Plugin 'posva/vim-vue'                                " syntax highlighting for vueJS
Plugin 'ryanoasis/vim-devicons'                       " font icon integration
Plugin 'sunaku/vim-ruby-minitest'                     " highlighting for minitest
Plugin 'thoughtbot/vim-rspec'                         " allow tests running from vim
Plugin 'tpope/vim-bundler'                            " support helpers for bundler
Plugin 'tpope/vim-endwise'                            " add `end` in ruby and other scripts
Plugin 'tpope/vim-fugitive'                           " look in .git/ctags for ctags index
Plugin 'tpope/vim-projectionist'                      " define alt files per project
Plugin 'tpope/vim-rails'                              " directory navigation and syntax for rails
Plugin 'tpope/vim-rake'                               " configures path for lib and ext directories on ruby and rails projects
Plugin 'tpope/vim-repeat'                             " allow . repeat on plugin commands
Plugin 'tpope/vim-rhubarb'                            " :Gbrowse to get GH url
Plugin 'tpope/vim-surround'                           " add paren and quote helpers
Plugin 'tpope/vim-unimpaired'                         " handy bracket mappings
Plugin 'vim-ruby/vim-ruby'                            " support for running ruby
Plugin 'vim-scripts/tComment'                         " comment with `gc`
Plugin 'w0rp/ale'                                     " async linter
Plugin 'yegappan/greplace'                            " global search and replace

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
