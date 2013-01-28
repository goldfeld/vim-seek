" ==============================================================================
" File:          plugin/seek.vim
" Description:   Motion for seeking to a pair of characters in the current line.
" Author:        Vic Goldfeld <github.com/goldfeld>
" Version:       0.2
" ReleaseDate:   2013-01-26
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
    execute 'normal! '.v:count.'x'
    startinsert
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

function! s:seekJump()
  if v:count >= 1
    execute 'normal! '.v:count.'x'
    startinsert
  else
		let c1 = getchar()
		let c2 = getchar()
		let line = getline('.')
		let pos = getpos('.')[2]
		let seek = stridx(l:line[l:pos :], nr2char(l:c1).nr2char(l:c2))
		if l:seek != -1
			execute 'normal! 0'.(l:pos + l:seek).'lvaw'
		endif
	endif
endfunction

function! s:seekJumpBack()
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = strridx(l:line[: l:pos + 1], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.l:seek.'lvaw'
  endif
endfunction

silent! nnoremap <unique> <Plug>(seek-seek)
      \ :<C-U>call <SID>seek(0)<CR>
silent! onoremap <unique> <Plug>(seek-seek)
      \ :<C-U>call <SID>seek(1)<CR>
silent! onoremap <unique> <Plug>(seek-seek-cut)
      \ :<C-U>call <SID>seek(0)<CR>
silent! onoremap <unique> <Plug>(seek-jump)
      \ :<C-U>call <SID>seekJump()<CR>
silent! nnoremap <unique> <Plug>(seek-back)
      \ :<C-U>call <SID>seekBack(0)<CR>
silent! onoremap <unique> <Plug>(seek-back)
      \ :<C-U>call <SID>seekBack(0)<CR>
silent! onoremap <unique> <Plug>(seek-back-cut)
      \ :<C-U>call <SID>seekBack(1)<CR>
silent! onoremap <unique> <Plug>(seek-jump-back)
      \ :<C-U>call <SID>seekJumpBack()<CR>

if !get(g:, 'seek_no_default_key_mappings', 0)
  nmap <silent> s <Plug>(seek-seek)
  omap <silent> s <Plug>(seek-seek)
  " x is mnemonic for 'cut short [of the seek target]'
  omap <silent> x <Plug>(seek-seek-cut)
  omap <silent> o <Plug>(seek-jump)

  nmap <silent> S <Plug>(seek-back)
  omap <silent> S <Plug>(seek-back)
  omap <silent> X <Plug>(seek-back-cut)
  omap <silent> O <Plug>(seek-jump-back)
endif

" TODO allow remapping the keys
"## Remapping Seek
"
"If you wish to leave substitute alone, a good candidate is the `\`/`|` pair, for seeking forward and backwards, respectively.
"
"You can change seek's default mapping in your vimrc:
"
"  let g:SeekForward = '\'
"  let g:s:seekBackward = '|'
"
"  let g:SeekCutShortForward = '|'
"  let g:SeekCutShortBackward = '|'
"
"  let g:s:seekJumpForward = '
"
"
"  <cursor>L{a}rem ipsum d{b}l{c}r sit amet.
"
"[link to other plugins](http://blabla.com)
"![animated demonstration](http://blablable.com)
