if exists('g:loaded_mykeymap') || &cp
  finish
endif
let g:loaded_mykeymap = 1

function! s:checkRequirements() abort
  let l:unsupported = 0

  if has('nvim')
    let l:unsupported = !has('nvim-0.3.2')
  else
    let l:unsupported = !has('patch-8.0.1630')
  endif

  if l:unsupported == 1
    echohl Error
    echom "myKeymap requires at least Vim 8.0.1630 or Neovim 0.3.2, but you're using an older version."
    echom "Please upgrade your (neo)vim."
    echohl None
    finish
  elseif (&rtp =~ '\v^(.*fzf\.vim)@!.*$')
    echohl Error
    echom 'myKeymap depends on junegunn/fzf.vim, please install/load that first.'
    echohl None
    finish
  endif
endfunction

call s:checkRequirements()

command! -bar -bang -nargs=0 MyKeymap
      \ execute mykeymap#show()

augroup mykeymap-init
  autocmd!
  autocmd VimEnter * ++once call mykeymap#init()
augroup END
