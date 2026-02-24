" Vim configurations specific to devpod

set clipboard=unnamedplus          " copy to the system clipboard

source ~/.dotfiles/shared/.vimrc

" Override GBrowse to copy URL to clipboard via OSC 52 (no browser in container)
function! GBrowseAndCopy()
  redir => url
  silent :.GBrowse!
  redir END
  let url = trim(url)
  if url != ''
    call system(expand('$HOME') . '/.dotfiles/devpod/bin/browser ' . shellescape(url) . ' > /dev/tty 2>&1')
    redraw!
    echo "URL copied to clipboard: " . url
  endif
endfunction

nmap <leader>br :call GBrowseAndCopy()<cr>
