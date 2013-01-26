" ==============================================================================
" File:          autoload/seek.vim
" Description:   Motion for seeking to a pair of characters in the current line.
" Author:        Vic Goldfeld <github.com/goldfeld>
" Version:       0.1
" ReleaseDate: 	 2013-01-17
" License:       Licensed under the same terms as Vim itself.
" ==============================================================================

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
