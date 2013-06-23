# vim-seek [![Flattr this plugin](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=goldfeld&url=https://github.com/goldfeld/vim-seek&title=vim-seek&language=en&tags=github&category=software)

Seek makes navigating long lines effortless, acting like f but taking two characters.

## Introduction

Seek is a vim plugin that aims to be your go-to characterwise motion workhorse. The motion seek, summoned with `s` by default, is similar to `f`, but instead of **one** it expects **two** characters. This greatly reduces the possible matches within the line and mostly allows you to get anywhere in a line with three keystrokes. Your cursor is left off at the first character typed, so if you seek to "th" your cursor will now be at "t". The forward seek motion is complemented by `S`, which seeks backwards.

## Motivation

The idea was borne out of frustration with getting at arbitrary points in longer lines, especially ones where navigating by word—on top of needing precise counts—gets mangled by symbols. The motion `f` often misfires by taking you to an earlier spot than where you aimed. And a full `/` search is often too much for a simple seek, needing an extra `<Enter>` and leaving a highlight, and might take you away from the current line. Seek only works within the line.

## What about substitute?

Vim maps the key `s` to substitute. That it is the perfect mnemonic to seek is a fortunate coincidence, but the choice was made because substitute (without a count) is an often inefficient command, being—ironically—easily substituted by others. Seek doesn't take a count by default, so whenever you supply a count to `s` it will map to the substitute command. However, if you don't use the substitute commmand at all, you can add `let g:seek_subst_disable = 1` to your `.vimrc` in order to allow counts for actual seeks.

The single character substitution can be accomplished with either `1s` or `cl`. And `S`, which is remapped to seek backwards, is completely substituted by `cc`.

However, if you don't want to give up substitute, you can scroll down to the Customization section.

## I already use EasyMotion..

Seek solves a different problem, and both are powerful tools. I use EasyMotion myself and love it—it's great for navigating across lines and around the file. But within the line, seek has more speed, for a very important reason: with seek you already know the keys you need to type before you even type `s`. Using EasyMotion there's a split second delay for it to generate the targets and another for your brain to process them. With seek you just type three quick keystrokes; you already know what to type.

## Advanced

Additional motions are provided as operator-pending only. That is, they only work when used after `d`, `c` or `y`, and not by themselves.

The motion `x` is to seek what `t` is to `f`. Standing for 'cut short \[of the target\]', it acts up to the first character typed, but doesn't include it. This is in contrast to `s` itself, which does include the first character typed—to keep it consistent with `f` behavior—but not the second character.

### Leaping motions

My personal favorites, `r` (remote leap) and `p` (presential leap) act on the next word containing the characters typed. They're the equivalent of `iw`, but `r` snipes the target word from a distance, and `p` leaps to the target and stays there. So you can use `yrth` to yank the next word containing "th" without leaving your position (in reality vim goes there and leaps back), and that's useful for pasting it to where you are. Or you can type `code` to leap to the next word with "de", deleting around it (aw) and leaving you in insert mode.

Whereas `r` and `p` use the inner word text object, the respective `u` and `o` are the equivalent outer word `aw`.

To enable the leaping mappings you need to add the following to your vimrc: `let g:seek_enable_jumps = 1`. They don't work in diff mode by default, because the mode uses `dp` and `do` for other purposes, but you can override this by also adding `let g:seek_enable_jumps_in_diff = 1` to your vimrc.

As expected, all these advanced mappings are complemented by their capital letter versions, which operate backwards.

### Customization

You can customize any of the keys that seek binds by adding lines such as the following to your vimrc.

Change s and S:

`let g:SeekKey = '<Space>'`
`let g:SeekBackKey = '<S-Space>'` // note: <S-Space> doesn't work in terminal vim.

Change x and X:

`let g:SeekCutShortKey = '-'`
`let g:SeekBackCutShortKey = '+'`

Change p and P:

`let g:seekJumpPresentialInnerKey = '<Leader>p'`
`let g:seekBackJumpPresentialInnerKey = '<Leader>P'`

Change r and R:

`let g:seekJumpRemoteInnerKey = '<Leader>r'`
`let g:seekBackJumpRemoteInnerKey = '<Leader>R'`

Change o and O:

`let g:seekJumpPresentialAroundKey = '<Leader>o'`
`let g:seekBackJumpPresentialAroundKey = '<Leader>O'`

Change u and U

`let g:seekJumpRemoteAroundKey = '<Leader>u'`
`let g:seekBackJumpPresentialInnerKey = '<Leader>U'`

Or you can use a shorthand version to redefine all seek keys:

`let g:SeekKeys = '<Space> <S-Space> - + <Leader>p <Leader>P' <Leader>r <Leader>R <Leader>o <Leader>O <Leader>u <Leader>U`

Though it must always follow the order, you can simply use the defaults for keys you don't want to change, and you can truncate the string to leave the remaining unchanged:

`let g:SeekKeys = 's S - +'` // will not change jump keys.

## Planned next

* Create a doc file moving customization help out of this readme.
* Repeating the last seek with `;` and `,` (same keys used for `f` and `t`).
* (Optional) Respect user's `ignorecase` and `smartcase` settings, so that you can seek to a capital letter by typing the lowercase character.
* Condensed jump mappings to allow you to use just one of `r` or `p` (or yet another key) for all jump motions, whereby you define which you want to be remote and which presential (e.g. `c` lends itself more to being presential, `y` to be remote, while `d` has good use of both).
