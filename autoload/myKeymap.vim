let s:_myKeymapSettings = {
  \ 'show_details': ['action'],
  \ 'disable_cache': 0,
  \ }

" TODO: implement recursive search for nested sources
function! s:getSourceFiles() abort
  let l:vimRcFile = fnamemodify($MYVIMRC, ':p')
  let l:sources = [l:vimRcFile]

  try
    for line in readfile(l:vimRcFile, '')
      let l:match = matchlist(line, '\v^%(\s+)?source (%(.*)\.vim)')
      if !empty(l:match) | call add(l:sources, l:match[1]) | endif
    endfor
    return l:sources
  catch /E484/
    echohl Error
    echom 'Your (neo)vim configuration cannot be found or is inaccessible.'
    echohl None
    return []
  endtry
endfunction

function! s:createKeymapItem(raw) abort
  return {
    \ 'shortcut': a:raw[2],
    \ 'name': a:raw[4],
    \ 'mode': a:raw[1],
    \ 'action': a:raw[3],
    \ 'source': a:raw[5] . ':' . a:raw[6],
    \ }
endfunction

function! s:extractKeymaps(file) abort
  let l:keymaps = []

  try
    let l:filePath = fnamemodify(a:file, ':p')
    let l:lines = readfile(l:filePath, '')
    let l:ln = 0
    for line in l:lines
      let l:ln += 1
      let l:annotation = matchlist(line, '\v^%(\s+)?\"\ \@\((\S.*)\)')
      if empty(l:annotation) | continue | endif
      let l:match = matchlist(l:lines[l:ln], '\v^%(\s+)?(%([nvxl])n|%([nvxoilc])m|%([oict])no|%([lt])ma|%([sic])nor|%([nvsxoilct])?%(nore)?map|map!)\s([^ ]+)\s(.*)$')
      if empty(l:match) | continue | endif
      let l:match = l:match[:3] + [l:annotation[1], l:filePath, l:ln]
      call add(l:keymaps, s:createKeymapItem(l:match))
    endfor
  catch /E484/
    echohl Error
    echom printf('Source was not found: %s', a:file)
    echohl None
  finally
    return l:keymaps
  endtry
endfunction

function! s:recognizeMode(value)
  if (a:value =~ '\v^map$')
    return 'NVO'
  elseif (a:value =~ '\v^map\!|no%(remap)?\!$')
    return 'IC'
  elseif (a:value =~ '\v^smap|snor%(e%(map)?)?$')
    return 'S'
  elseif (a:value =~ '\v^tma%(p)?|tno%(remap)?$')
    return 'T'
  elseif (a:value =~ '\v^nm%(ap)?|nn%(oremap)?$')
    return 'N'
  elseif (a:value =~ '\v^vm%(ap)?|vn%(oremap)?$')
    return 'V'
  elseif (a:value =~ '\v^xm%(ap)?|xn%(oremap)?$')
    return 'X'
  elseif (a:value =~ '\v^om%(ap)?|ono%(remap)?$')
    return 'O'
  elseif (a:value =~ '\v^im%(ap)?|ino%(r%(emap)?)?$')
    return 'I'
  elseif (a:value =~ '\v^lm%(a%(p)?)?|ln%(oremap)?$')
    return 'L'
  elseif (a:value =~ '\v^cm%(ap)?|cno%(r%(emap)?)?$')
    return 'C'
  else
    return '?'
  endif
endfunction

function! s:renderDetails(value) abort
  let l:details = ''

  for detail in s:myKeymapSettings.show_details
    if !has_key(a:value, detail) | continue | endif
    let l:details .= printf(', %s: `%s`', detail, a:value[detail])
  endfor

  return l:details
endfunction

function! s:renderResult(value) abort
  let l:mode = s:recognizeMode(a:value['mode'])
  let l:details = s:renderDetails(a:value)
  return printf("%s %s (mode: `%s`%s)", a:value['shortcut'], a:value['name'], l:mode, l:details)
endfunction

function! s:blackHoleSink(cmd) abort
  " we do nothing with the selected mapping
  let @_ = a:cmd
endfunction

function! s:setKnownKeymaps() abort
  let l:sourceFiles = s:getSourceFiles()
  let s:knownKeymaps = []

  for file in l:sourceFiles
    let l:extracted = s:extractKeymaps(file)
    call map(l:extracted, 's:renderResult(v:val)')
    let s:knownKeymaps += l:extracted
  endfor
endfunction

function! mykeymap#init() abort
  let s:myKeymapSettings = deepcopy(get(g:, 'myKeymapSettings', {}))
  for [l:key, l:value] in items(s:_myKeymapSettings)
    if type(l:value) == 4
      if !has_key(s:myKeymapSettings, l:key)
        let s:myKeymapSettings[l:key] = {}
      endif
      call extend(s:myKeymapSettings[l:key], l:value, 'keep')
    elseif !has_key(s:myKeymapSettings, l:key)
      let s:myKeymapSettings[l:key] = l:value
    endif
    unlet l:value
  endfor

  if (!exists('s:knownKeymaps'))
    call s:setKnownKeymaps()
  endif
endfunction

function! mykeymap#show() abort
  if (s:myKeymapSettings.disable_cache)
    call s:setKnownKeymaps()
  endif

  call fzf#run(fzf#wrap({'source': s:knownKeymaps,
      \ 'sink': function('s:blackHoleSink'),
      \ 'options': '--prompt "myKeymap> " --no-preview'}))
endfunction
