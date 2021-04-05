" use Ag to search the dir for the word under curor
fun! FindWordUnderCursor()
  let word = expand("<cword>")
  sil! exe 'Ag! \b' . word . '\b'
endfun

" Format JSON with python script
fun! FormatJSON()
  %!python -m json.tool
  setl fdl=1 sts=4 sw=4 ts=4
endfun

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

" Smart tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction

" Get the url on the current line if there is one
function! ExtractUrlFromCurrentLine()
  return matchstr(getline("."), "http[^ ]*[^)]")
endfunction

" Open the url on the current line in the default browser
function! OpenUrlOnCurrentLineInBrowser()
  let url = ExtractUrlFromCurrentLine()
  exec "!open" url
endfunction

" Fix `gx` url command
" See https://github.com/vim/vim/issues/4738#issuecomment-714609892
if has('macunix')
  function! OpenURLUnderCursor()
    let s:uri = matchstr(getline('.'), '[a-z]*:\/\/[^ >,;()]*')
    let s:uri = shellescape(s:uri, 1)
    if s:uri != ''
      silent exec "!open '".s:uri."'"
      :redraw!
    endif
  endfunction
  nnoremap gx :call OpenURLUnderCursor()<CR>
endif
