" make sure vim-plug is installed so plugins can be installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" after adding new plugins write, source, and run :PlugInstall
" highlight all and :sort to sort
call plug#begin('~/.vim/plugged') " Specify a directory for plugins

" Make sure to use single quotes
" Plug 'SirVer/ultisnips'                             " ultimate snippet solution for Vim
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim' " find or install fzf
Plug 'AndrewRadev/vim-eco'                          " .eco syntax highlighting
Plug 'AoLab/vim-avro'                               " sytnax highlighting for avro schemas
Plug 'airblade/vim-gitgutter'                       " show git changes in gutter
Plug 'calebsmith/vim-lambdify'                      " conceal js functions with lambda
Plug 'christoomey/vim-run-interactive'              " allow interactive shell
Plug 'christoomey/vim-tmux-navigator'               " allow ctrl+hjkl to navigate between vim and tmus
Plug 'christoomey/vim-tmux-runner'                  " allows sending commands to tmux from vim
Plug 'crusoexia/vim-javascript-lib'                 " syntax highlighting for common JS libraries
Plug 'easymotion/vim-easymotion'                    " vim motions on speed
Plug 'elixir-editors/vim-elixir'                      " elixir support
Plug 'hashivim/vim-terraform'                       " terraform syntax and :Terraform command
Plug 'henrik/vim-indexed-search'                    " display search count
Plug 'honza/vim-snippets'                           " snippets
Plug 'itchyny/lightline.vim'                        " vim status bar coloring
Plug 'jbgutierrez/vim-partial'                      " extract haml partials
Plug 'jgdavey/vim-blockle'                          " toggle ruby do and {} blocks
Plug 'jiangmiao/auto-pairs'                         " open and close brackets
Plug 'joker1007/vim-ruby-heredoc-syntax'            " heredoc ruby highlighing
Plug 'kana/vim-textobj-user'                        " dependency of nelstrom/vim-textobj-rubyblock
Plug 'kchmck/vim-coffee-script'                     " syntax for coffeescript
Plug 'lambdalisue/vim-pyenv'                        " sync pyenv version. NOTE: known slow performance (only on boot time)
Plug 'maksimr/vim-jsbeautify'                       " format js and html pages
Plug 'mattn/emmet-vim'                              " html and css editing
Plug 'maximbaz/lightline-ale'                       " ale indicator for lightline
Plug 'mhinz/vim-startify'                           " fancy startup screen
Plug 'michaeljsmith/vim-indent-object'              " vii to highlight lines at same indent level
Plug 'nanotech/jellybeans.vim', { 'tag': 'v1.6' }   " color scheme
Plug 'nelstrom/vim-textobj-rubyblock'               " provide ruby text objects
Plug 'nelstrom/vim-visual-star-search'              " * to serach current word
Plug 'onemanstartup/vim-slim'                       " syntax for slim. Use this over the official slim-template/vim-slim plugin for way better speed. See https://github.com/slim-template/vim-slim/issues/19#issuecomment-50607474
Plug 'posva/vim-vue'                                " syntax highlighting for vueJS
Plug 'ryanoasis/vim-devicons'                       " font icon integration
Plug 'sunaku/vim-ruby-minitest'                     " highlighting for minitest
Plug 'thoughtbot/vim-rspec'                         " allow tests running from vim
Plug 'tpope/vim-bundler'                            " support helpers for bundler
Plug 'tpope/vim-endwise'                            " add `end` in ruby and other scripts
Plug 'tpope/vim-fugitive'                           " look in .git/ctags for ctags index
Plug 'tpope/vim-projectionist'                      " define alt files per project
Plug 'tpope/vim-rails'                              " directory navigation and syntax for rails
Plug 'tpope/vim-rake'                               " configures path for lib and ext directories on ruby and rails projects
Plug 'tpope/vim-repeat'                             " allow . repeat on plugin commands
Plug 'tpope/vim-rhubarb'                            " :Gbrowse to get GH url
Plug 'tpope/vim-surround'                           " add paren and quote helpers
Plug 'tpope/vim-unimpaired'                         " handy bracket mappings
Plug 'leafgarland/typescript-vim'                   " Typescript support for vim
Plug 'vim-ruby/vim-ruby'                            " support for running ruby
Plug 'vim-scripts/tComment'                         " comment with `gc`
Plug 'w0rp/ale'                                     " async linter
Plug 'yegappan/greplace'                            " global search and replace

call plug#end() " Initialize plugin system
