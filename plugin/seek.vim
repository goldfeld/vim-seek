" ==============================================================================
" File:          plugin/seek.vim
" Description:   Motion for seeking to a pair of characters in the current line.
" Author:        Vic Goldfeld <github.com/goldfeld>
" Version:       0.2
" ReleaseDate: 	 2013-01-26
" License:       Licensed under the same terms as Vim itself.
" ==============================================================================

if exists('g:loaded_seek') || &cp
  finish
endif
let g:loaded_seek = 1

" TODO https://github.com/vim-scripts/InsertChar/blob/master/plugin/InsertChar.vim
" TODO follow ignorecase and smartcase rules for alpha characters (and add to readme)
" TODO remote yank option for the 'yc' motion
function! Seek(plus)
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

function! SeekBack(plus)
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = strridx(l:line[: l:pos - 1], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.(l:seek + a:plus).'l'
  endif
endfunction

function! SeekJump()
	let c1 = getchar()
	let c2 = getchar()
	let line = getline('.')
	let pos = getpos('.')[2]
	let seek = stridx(l:line[l:pos :], nr2char(l:c1).nr2char(l:c2))
	if l:seek != -1
		execute 'normal! 0'.(l:pos + l:seek).'lviw'
	endif
endfunction

function! SeekJumpBack()
  let c1 = getchar()
  let c2 = getchar()
  let line = getline('.')
  let pos = getpos('.')[2]
  let seek = strridx(l:line[: l:pos + 1], nr2char(l:c1).nr2char(l:c2))
  if l:seek != -1
    execute 'normal! 0'.l:seek.'lviw'
  endif
endfunction

:nnoremap s :<C-U>call Seek(0)<CR>
:onoremap s :<C-U>call Seek(1)<CR>
" c is mnemonic for 'cut short [of the seek target]'
:onoremap c :<C-U>call Seek(0)<CR>
:onoremap j :<C-U>call SeekJump()<CR>

:nnoremap S :<C-U>call SeekBack(0)<CR>
:onoremap S :<C-U>call SeekBack(0)<CR>
:onoremap C :<C-U>call SeekBack(1)<CR>
:onoremap J :<C-U>call SeekJumpBack()<CR>

" TODO allow remapping the keys
"## Remapping Seek
"
"If you wish to leave substitute alone, a good candidate is the `\`/`|` pair, for seeking forward and backwards, respectively.
"
"You can change seek's default mapping in your vimrc:
"
"	let g:SeekForward = '\'
"	let g:SeekBackward = '|'
"
"	let g:SeekCutShortForward = '|'
"	let g:SeekCutShortBackward = '|'
"
"	let g:SeekJumpForward = '
"
"
"	<cursor>L{a}rem ipsum d{b}l{c}r sit amet.
"
"[link to other plugins](http://blabla.com)
"![animated demonstration](http://blablable.com)
