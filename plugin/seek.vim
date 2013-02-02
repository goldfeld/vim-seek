" ==============================================================================
" File:          plugin/seek.vim
" Description:   Motion for seeking to a pair of characters in the current line.
" Author:        Vic Goldfeld <github.com/goldfeld>
" Version:       0.5
" ReleaseDate:   2013-01-30
" License:       Licensed under the same terms as Vim itself.
" ==============================================================================

if exists('g:loaded_seek') || &cp
  finish
endif
let g:loaded_seek = 1

" TODO https://github.com/vim-scripts/InsertChar/blob/master/plugin/InsertChar.vim
" TODO follow ignorecase and smartcase rules for alpha characters (and add to readme)
" TODO remote yank option for the 'yc' motion
function! s:seek(plus)
  if v:count >= 1
    execute 'normal! c'.v:count.'l'
  else
    let c1 = getchar()
    let c2 = getchar()
    let line = getline('.')
    let pos = getpos('.')[2]
    let seek = stridx(l:line[l:pos :], nr2char(l:c1).nr2char(l:c2))
    if l:seek != -1
      execute 'normal! 0'.(l:pos + l:seek + a:plus).'l'
    endif
  endif
endfunction

function! s:seekBack(plus)
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = strridx(l:line[: l:pos - 1], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.(l:seek + a:plus).'l'
  endif
endfunction

function! s:seekJumpPresential(textobj)
  if &diff && !get(g:, 'seek_enable_jumps_in_diff', 0) | return | endif
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = stridx(l:line[l:pos :], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.(l:pos + l:seek).'lv'.a:textobj
  endif
endfunction

function! s:seekBackJumpPresential(textobj)
  if &diff && !get(g:, 'seek_enable_jumps_in_diff', 0) | return | endif
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = strridx(l:line[: l:pos - 1], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.l:seek.'lv'.a:textobj
  endif
endfunction

function! s:seekJumpRemote(textobj)
  if &diff && !get(g:, 'seek_enable_jumps_in_diff', 0) | return | endif
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let cursor = getpos('.')
  let pos = l:cursor[2]
  let seek = stridx(l:line[l:pos :], nr2char(l:c1).nr2char(l:c2))

  let cmd = "execute 'call cursor(".l:cursor[1].", ".l:pos.")'"
  call s:registerCommand('CursorMoved', cmd, 'remoteJump')
  
  if l:seek != -1
    execute 'normal! 0'.(l:pos + l:seek).'lv'.a:textobj
  endif
endfunction

function! s:seekBackJumpRemote(textobj)
  if &diff && !get(g:, 'seek_enable_jumps_in_diff', 0) | return | endif
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let cursor = getpos('.')
  let pos = l:cursor[2]
  let seek = strridx(l:line[: l:pos - 1], nr2char(l:c1).nr2char(l:c2))

  let cmd = "execute 'call cursor(".l:cursor[1].", ".l:pos.")'"
  call s:registerCommand('CursorMoved', cmd, 'remoteJump')

  if l:seek != -1
    execute 'normal! 0'.l:seek.'lv'.a:textobj
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


silent! nnoremap <unique> <Plug>(seek-seek)
      \ :<C-U>call <SID>seek(0)<CR>
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
"	for key in split(seekKeys, ' ')
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

execute "nmap <silent> ".seekSeek." <Plug>(seek-seek)"
execute "omap <silent> ".seekSeek." <Plug>(seek-seek)"
execute "omap <silent> ".seekCut." <Plug>(seek-seek-cut)"

execute "nmap <silent> ".seekBack." <Plug>(seek-back)"
execute "omap <silent> ".seekBack." <Plug>(seek-back)"
execute "omap <silent> ".seekBackCut." <Plug>(seek-back-cut)"

if get(g:, 'seek_enable_jumps', 0)
  execute "omap <silent> ".seekJumpPI." <Plug>(seek-jump-presential-iw)"
  execute "omap <silent> ".seekJumpRI." <Plug>(seek-jump-remote-iw)"

  execute "omap <silent> ".seekJumpPA." <Plug>(seek-jump-presential-aw)"
  execute "omap <silent> ".seekJumpRA." <Plug>(seek-jump-remote-aw)"

  execute "omap <silent> ".seekBackJumpPI." <Plug>(seek-back-jump-presential-iw)"
  execute "omap <silent> ".seekBackJumpRI." <Plug>(seek-back-jump-remote-iw)"

  execute "omap <silent> ".seekBackJumpPA." <Plug>(seek-back-jump-presential-aw)"
  execute "omap <silent> ".seekBackJumpRA." <Plug>(seek-back-jump-remote-aw)"
endif

"  <cursor>L{a}rem ipsum d{b}l{c}r sit amet.
"
"[link to other plugins](http://blabla.com)
"![animated demonstration](http://blablable.com)
