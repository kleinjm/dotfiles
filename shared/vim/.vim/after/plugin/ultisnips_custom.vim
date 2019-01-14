if !exists('did_plugin_ultisnips')
  finish
endif

augroup ultisnips_custom
  au!
  au BufNewFile * silent! call templates#InsertSkeleton()
  au User ProjectionistActivate silent! call templates#InsertSkeleton()
augroup END
