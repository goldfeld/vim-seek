"" =============================================================================
"" File:          plugin/seek.vim
"" Description:   Motion for seeking to a pair of characters in the current line.
"" Author:        Vic Goldfeld <github.com/goldfeld>
"" Version:       0.7
"" ReleaseDate:   2013-03-10
"" License:       MIT License (see below)
""
"" Copyright (C) 2013 Vic Goldfeld under the MIT License.
""
"" Permission is hereby granted, free of charge, to any person obtaining a 
"" copy of this software and associated documentation files (the "Software"), 
"" to deal in the Software without restriction, including without limitation 
"" the rights to use, copy, modify, merge, publish, distribute, sublicense, 
"" and/or sell copies of the Software, and to permit persons to whom the 
"" Software is furnished to do so, subject to the following conditions:
""
"" The above copyright notice and this permission notice shall be included in 
"" all copies or substantial portions of the Software.
""
"" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
"" OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
"" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
"" THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
"" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
"" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
"" OTHER DEALINGS IN THE SOFTWARE.
"" =============================================================================

if exists('g:loaded_seek') || &cp
  finish
endif
let g:loaded_seek = 1

let s:charAliases = {}
" char aliases augment alphabet case insensitivity by allowing you to type
" a key to mean another, when doing a seek.
" e.g. user has `let g:seek_char_aliases = '[{ ]} 9( 0)'` on vimrc
for pair in split(get(g:, 'seek_char_aliases', ''))
  if len(pair) == 2
    let s:charAliases[pair[0]] = pair[1]
  endif
endfor

" TODO https://github.com/vim-scripts/InsertChar/blob/master/plugin/InsertChar.vim
" TODO follow ignorecase and smartcase rules for alpha characters (and add to readme)

function! s:compareSeekFwd(challenger, current)
  return a:current == -1 || (a:challenger != -1 && a:challenger < a:current)
endfunction
function! s:compareSeekBwd(challenger, current)
  return a:current == -1 || a:challenger > a:current
endfunction

" find the `cnt`th occurence of "c1c2" after the current cursor position
" `pos` in `text
function! s:findTargetFwd(pos, cnt, text)
  let c1 = getchar()
  " abort seek if first char is <Esc>
  if l:c1 == 27 | return -1 | endif
  let c2 = getchar()
  let pos = a:pos
  let cnt = a:cnt

  while cnt > 0
    let seek = s:seekindex(a:text, l:c1, l:c2, l:pos,
      \ 'stridx', 's:compareSeekFwd')
    let l:pos = l:seek + 1 " so as to not repeatedly find the same occurence
    let l:cnt = l:cnt - 1
  endwhile

  " return pos to beginning of matching char-pair
  return l:seek == -1 ? -1 : l:pos - 1
endfunction

" find the `cnt`th occurence of "c1c2" before the current cursor position
" `pos` in `text`
function! s:findTargetBwd(pos, cnt, text)
  let c1 = getchar()
  " abort seek if first char is <Esc>
  if l:c1 == 27 | return -1 | endif
  let c2 = getchar()
  let pos = a:pos
  let cnt = a:cnt

  while cnt > 0
    let haystack = a:text[: l:pos - 1]
    let seek = s:seekindex(l:haystack, l:c1, l:c2, len(l:haystack),
      \ 'strridx', 's:compareSeekBwd')
    let l:pos = l:seek - 1 " so as to not repeatedly find the same occurence
    let l:cnt = l:cnt - 1
  endwhile

  " return pos to beginning of matching char-pair
  return l:seek == -1 ? -1 : l:pos + 1
endfunction

" we use the souped up str(r)idx functions if the user hasn't explicited told
" us not to ignore case, plus he has one of: native vim ignorecase settings,
" explicitly told us to ignore case, or defined any custom char aliases.
if !get(g:, 'seek_noignorecase', 0) && (&ignorecase || &smartcase
  \ || get(g:, 'seek_ignorecase', 0) || len(get(g:, 'seek_char_aliases', {})))

  function! s:seekindex(text, c1, c2, start, seekfn, comparefn)
    let char1 = nr2char(a:c1)
    let char2 = nr2char(a:c2)
    let Index = function(a:seekfn)
    let Compare = function(a:comparefn)

    let seek = Index(a:text, l:char1 . l:char2, a:start)
    let pureseek = l:seek
    let [one, two] = ['', '']

    " a to z
    if a:c1 >= 97 && a:c1 <= 122
      let l:one = nr2char(a:c1 - 32)
      let seek2 = Index(a:text, l:one . l:char2, a:start)
      if Compare(seek2, l:seek) | let l:seek = seek2 | endif
    elseif l:pureseek != -1 && a:c1 >= 65 && a:c1 <= 90 | return l:pureseek
    else
      let symbol = get(s:charAliases, l:char1, '')
      if l:symbol != ''
        let l:one = l:symbol
        let seek2 = Index(a:text, l:one . l:char2, a:start)
        if Compare(seek2, l:seek) | let l:seek = seek2 | endif
      endif
    endif

    if a:c2 >= 97 && a:c2 <= 122
      let l:two = nr2char(a:c2 - 32)
      let seek3 = Index(a:text, l:char1 . l:two, a:start)
      if Compare(seek3, l:seek) | let l:seek = seek3 | endif
    elseif l:pureseek != -1 && a:c2 >= 65 && a:c2 <= 90 | return l:pureseek
    else
      let symbol = get(s:charAliases, l:char2, '')
      if l:symbol != ''
        let l:two = l:symbol
        let seek3 = Index(a:text, l:char1 . l:two, a:start)
        if Compare(seek3, l:seek) | let l:seek = seek3 | endif
      endif
    endif

    if l:one != '' && l:two != ''
      let seek4 = Index(a:text, l:one . l:two, a:start)
      if Compare(seek4, l:seek) | let l:seek = seek4 | endif
    endif

    return l:seek
  endfunction

else
  function! s:seekindex(text, c1, c2, start, seekfn, comparefn)
    let Index = function(a:seekfn)
    return Index(a:text, nr2char(a:c1).nr2char(a:c2), a:start)
  endfunction
endif

function! s:seek(plus)
  let pos = col('.')
  let line = getline('.')
  let seek = s:findTargetFwd(l:pos, v:count1, l:line)
  if l:seek != -1
    call cursor(line('.'), 1 + l:seek + a:plus)
  endif
endfunction

function! s:seekOrSubst(plus)
  if v:count >= 1 | call feedkeys('c' . v:count . 'l')
  else | call s:seek(a:plus)
  endif
endfunction

function! s:seekBack(plus)
  let pos = col('.')
  let line = getline('.')
  let seek = s:findTargetBwd(l:pos, v:count1, l:line)
  if l:seek != -1
    call cursor(line('.'), 1 + l:seek + a:plus)
  endif
endfunction

function! s:seekJumpPresential(textobj)
  if &diff && get(g:, 'seek_use_vanilla_binds_in_diffmode', 0)
    \ && v:operator == 'd'
    if a:textobj == 'iw' | diffput | return | endif
    if a:textobj == 'aw' | diffget | return | endif
  endif
  let pos = col('.')
  let line = getline('.')
  let seek = s:findTargetFwd(l:pos, v:count1, l:line)
  if l:seek != -1
    call cursor(line('.'), 1 + l:seek)
    execute 'normal! v'.a:textobj
  endif
endfunction

function! s:seekBackJumpPresential(textobj)
  let pos = col('.')
  let line = getline('.')
  let seek = s:findTargetBwd(l:pos, v:count1, l:line)
  if l:seek != -1
    call cursor(line('.'), 1 + l:seek)
    execute 'normal! v'.a:textobj
  endif
endfunction

function! s:seekJumpRemote(textobj)
  let cursor = getpos('.')
  let pos = l:cursor[2]
  let line = getline('.')
  let seek = s:findTargetFwd(l:pos, v:count1, l:line)

  let cmd = "execute 'call cursor(" . l:cursor[1]. ", " . l:pos . ")'"
  call s:registerCommand('CursorMoved', cmd, 'remoteJump')

  if l:seek != -1
    call cursor(line('.'), 1 + l:seek)
    execute 'normal! v'.a:textobj
  endif
endfunction

function! s:seekBackJumpRemote(textobj)
  let cursor = getpos('.')
  let pos = l:cursor[2]
  let line = getline('.')
  let seek = s:findTargetBwd(l:pos, v:count1, l:line)

  " the remote back jump needs special treatment in repositioning the cursor,
  " to account for possible characters deleted; we do this by diffing the line
  " length before and after i.e. originalPos - (beforeLen - afterLen)
  let before = len(l:line)
  let cmd = "execute 'call cursor(" . l:cursor[1] . ", "
    \ . (l:pos - l:before) . " + len(getline(\".\")))'"
  call s:registerCommand('CursorMoved', cmd, 'remoteJump')

  if l:seek != -1
    call cursor(line('.'), 1 + l:seek)
    execute 'normal! v'.a:textobj
  endif
endfunction

" credit: Luc Hermitte
" http://code.google.com/p/lh-vim/source/search?q=register_for&origq=register_for&btnG=Search+Trunk
function! s:registerCommand(event, cmd, group)
  let group = a:group.'_once'
  let s:{group} = 0
  exe 'augroup '.group
  au!
  exe 'au '.a:event.' '.expand('%:p').' call s:registeredOnce('.string(a:cmd).','.string(group).')'
  augroup END
endfunction
function! s:registeredOnce(cmd, group)
  " We can't delete the current  autocommand => increment a counter
  if !exists('s:'.a:group) || s:{a:group} == 0
    let s:{a:group} = 1
    exe a:cmd
  endif
endfunction

if get(g:, 'seek_subst_disable', 0) != 0
  silent! nnoremap <unique> <Plug>(seek-seek)
        \ :<C-U>call <SID>seek(0)<CR>
else
  silent! nnoremap <unique> <Plug>(seek-seek)
        \ :<C-U>call <SID>seekOrSubst(0)<CR>
endif

silent! onoremap <unique> <Plug>(seek-seek)
      \ :<C-U>call <SID>seek(1)<CR>
silent! onoremap <unique> <Plug>(seek-seek-cut)
      \ :<C-U>call <SID>seek(0)<CR>

silent! nnoremap <unique> <Plug>(seek-back)
      \ :<C-U>call <SID>seekBack(0)<CR>
silent! onoremap <unique> <Plug>(seek-back)
      \ :<C-U>call <SID>seekBack(0)<CR>
silent! onoremap <unique> <Plug>(seek-back-cut)
      \ :<C-U>call <SID>seekBack(1)<CR>

silent! onoremap <unique> <Plug>(seek-jump-presential-iw)
      \ :<C-U>call <SID>seekJumpPresential('iw')<CR>
silent! onoremap <unique> <Plug>(seek-jump-presential-aw)
      \ :<C-U>call <SID>seekJumpPresential('aw')<CR>
silent! onoremap <unique> <Plug>(seek-jump-remote-iw)
      \ :<C-U>call <SID>seekJumpRemote('iw')<CR>
silent! onoremap <unique> <Plug>(seek-jump-remote-aw)
      \ :<C-U>call <SID>seekJumpRemote('aw')<CR>

silent! onoremap <unique> <Plug>(seek-back-jump-presential-iw)
      \ :<C-U>call <SID>seekBackJumpPresential('iw')<CR>
silent! onoremap <unique> <Plug>(seek-back-jump-remote-iw)
      \ :<C-U>call <SID>seekBackJumpRemote('iw')<CR>
silent! onoremap <unique> <Plug>(seek-back-jump-presential-aw)
      \ :<C-U>call <SID>seekBackJumpPresential('aw')<CR>
silent! onoremap <unique> <Plug>(seek-back-jump-remote-aw)
      \ :<C-U>call <SID>seekBackJumpRemote('aw')<CR>

"let seekKeys = get(g:, 'SeekKeys', '')
"if len(seekKeys) > 0
"  for key in split(seekKeys, ' ')
"else
let seekSeek = get(g:, 'SeekKey', 's')
let seekCut = get(g:, 'SeekCutShortKey', 'x')

let seekBack = get(g:, 'SeekBackKey', 'S')
let seekBackCut = get(g:, 'SeekBackCutShortKey', 'X')

let seekJumpPI = get(g:, 'seekJumpPresentialInnerKey', 'p')
let seekJumpRI = get(g:, 'seekJumpRemoteInnerKey', 'r')

let seekJumpPA = get(g:, 'seekJumpPresentialAroundKey', 'o')
let seekJumpRA = get(g:, 'seekJumpRemoteAroundKey', 'u')

let seekBackJumpPI = get(g:, 'seekBackJumpPresentialInnerKey', 'P')
let seekBackJumpRI = get(g:, 'seekBackJumpRemoteInnerKey', 'R')

let seekBackJumpPA = get(g:, 'seekBackJumpPresentialAroundKey', 'O')
let seekBackJumpRA = get(g:, 'seekBackJumpPresentialInnerKey', 'U')
"endif

execute "nmap <silent>" seekSeek "<Plug>(seek-seek)"
execute "omap <silent>" seekSeek "<Plug>(seek-seek)"
execute "omap <silent>" seekCut "<Plug>(seek-seek-cut)"

execute "nmap <silent>" seekBack "<Plug>(seek-back)"
execute "omap <silent>" seekBack "<Plug>(seek-back)"
execute "omap <silent>" seekBackCut "<Plug>(seek-back-cut)"

if get(g:, 'seek_enable_jumps', 0)
  execute "omap <silent>" seekJumpPI "<Plug>(seek-jump-presential-iw)"
  execute "omap <silent>" seekJumpRI "<Plug>(seek-jump-remote-iw)"

  execute "omap <silent>" seekJumpPA "<Plug>(seek-jump-presential-aw)"
  execute "omap <silent>" seekJumpRA "<Plug>(seek-jump-remote-aw)"

  execute "omap <silent>" seekBackJumpPI "<Plug>(seek-back-jump-presential-iw)"
  execute "omap <silent>" seekBackJumpRI "<Plug>(seek-back-jump-remote-iw)"

  execute "omap <silent>" seekBackJumpPA "<Plug>(seek-back-jump-presential-aw)"
  execute "omap <silent>" seekBackJumpRA "<Plug>(seek-back-jump-remote-aw)"
endif
