fun! s:try_insert(skel)
  execute "normal! i_" . a:skel . "\<c-r>=UltiSnips#ExpandSnippet()\<cr>"

  if g:ulti_expand_res == 0
    silent! undo
  endif

  return g:ulti_expand_res
endfun

fun! templates#InsertSkeleton() abort
  let filename = expand('%')

  " Abort on non-empty buffer
  if !(line('$') == 1 && getline('$') == '') " || filereadable(filename)
    return
  endif

  " Try skeleton key from projectionist
  if !empty('b:projectionist')
    for [root, value] in projectionist#query('skeleton')
      if s:try_insert(value)
        return
      endif
    endfor
  endif

  " Try generic _skel template as last resort
  call s:try_insert('skel')
endfun
