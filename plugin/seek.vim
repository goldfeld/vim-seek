" ==============================================================================
" File:          plugin/seek.vim
" Description:   Motion for seeking to a pair of characters in the current line.
" Author:        Vic Goldfeld <github.com/goldfeld>
" Version:       0.1
" ReleaseDate: 	 2013-01-17
" License:       Licensed under the same terms as Vim itself.
" ==============================================================================

if exists('g:loaded_seek') || &cp
  finish
endif
let g:loaded_seek = 1

:nnoremap s :<C-U>call g:Seek(0)<CR>
:onoremap s :<C-U>call g:Seek(1)<CR>
" c is mnemonic for 'cut short [of the seek target]'
:onoremap c :<C-U>call g:Seek(0)<CR>
:onoremap j :<C-U>call g:SeekJump()<CR>

:nnoremap S :<C-U>call g:SeekBack(0)<CR>
:onoremap S :<C-U>call g:SeekBack(0)<CR>
:onoremap C :<C-U>call g:SeekBack(1)<CR>
:onoremap J :<C-U>call g:SeekJumpBack()<CR>

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
