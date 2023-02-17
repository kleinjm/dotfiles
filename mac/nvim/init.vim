set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

imap <C-j> <Plug>(copilot-next)
imap <C-k> <Plug>(copilot-previous)

" Change the key mapping to <C-L> instead of <Tab>
imap <silent><script><expr> <C-L> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

source ~/.vimrc
