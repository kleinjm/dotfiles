" Switch between the last two files
nnoremap <leader><leader> <c-^>
" copy current relative file path to system clipboard
nnoremap <leader>cf :let @+ = expand("%")<cr>

" leader + i inserts binding.pry
map <Leader>i oKernel.binding.pry<ESC>0
" leader + d inserts debugger
map <Leader>db odebugger; // eslint-disable-line no-debugger<ESC>

" insert a frozen string literal tag at the top of the document and returns
" cursor to current position
map <Leader>r ggO# frozen_string_literal: true<ESC><cr>D<C-o>
" reindent the entire file
map <leader>= mzgg=G`z
" create parent directories. Good for new files in new dir
map <Leader>mk :call mkdir(expand('%:h'), 'p')<ESC>:w<cr>
" close all other tabs and splits but this one
map <leader>cl :only<esc>
" open the filepath of the current file to rename it
map <Leader>n :call RenameFile()<cr>

" reload vimrc with leader+so
nmap <leader>so :source $MYVIMRC<cr>
" Split edit your vimrc. Type space, v, r in sequence to trigger
nmap <leader>vr :tabe $MYVIMRC<cr>
" Pre-populate a split command with the current directory
nmap <leader>v :vnew <C-r>=escape(expand("%:p:h"), ' ') . '/'<cr>

" Edit the db/schema.rb Rails file in a split
nmap <leader>sc :vsp db/schema.rb<cr>

" change all single ' to double " in current file
nmap <leader>" :%s/\'/\"/g<cr><C-@><Esc>
" change all double " to single ' in current file
nmap <leader>' :%s/\"/\'/g<cr><C-@><Esc>
" show the current file on github
nmap <leader>br :.GBrowse<cr>
" git blame
nmap <leader>bl :Git blame<cr>
" open temp file to scratch on
map <Leader>tmp :vsp ~/.tempfile<CR>
" open my local zsh config
map <Leader>lcl :vsp $LOCAL_CONFIG<CR>
" open the url anywhere on the current line
map <Leader>url :call OpenUrlOnCurrentLineInBrowser()<CR><CR>

map <Leader> <Plug>(easymotion-prefix)

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

nnoremap <leader>f :FZF<cr>

noremap <Leader>g :Fzfc<cr>

" to edit the corresponding snippets file
nnoremap <leader>se :UltiSnipsEdit<cr>

" sort words on one line. See https://stackoverflow.com/a/1329899/2418828
vnoremap a d:execute 'normal i' . join(sort(split(getreg('"'))), ' ')<CR>
