# Introduction

Seek is a vim plugin that aims to make inline navigation effortless. The motion seek, summoned with `s` by default, is similar to `f`, but instead of **one** it expects **two** characters. This greatly reduces the possible matches within the line and mostly allows you to get anywhere in a line with three keystrokes. Your cursor is left off at the first character typed, so if you seek to `th' your cursor will now be at `t`. The forward seek motion is complemented by `S`, which seeks backwards.

# Motivation

The idea was borne out of the frustration with getting at arbitrary points in longer lines, especially ones where navigating by word--on top of needing precise counts--gets mangled by symbols. The motion `f` often misfires by taking you to an earlier spot than where you aimed. And a full `/` search is often too much for a simple seek, needing a extra `<Enter>' and leaving a highlight, and might take you away from the current line. Seek only works within the line.

# What about substitute?

Vim maps the key `s` to substitute. That it is the perfect mnemonic to seek is a fortunate coincidence, but the choice was made because substitute (without a count) is an often inefficient command, being--ironically--easily substituted by others. Seek doesn't take a count, so whenever you supply a count to `s` it will map to the substitute command. 

The single character substitution can be accomplished with either `1s` or `cl`. And `S`, which is remapped to seek backwards, is completely substituted by `cc`.

## Advanced

Aditional motions are provided as operator-pending-only. That is, they only work when used after d, c or y, and not by themselves.

The motion `c` is to seek what `t` is to `f`. Standing for 'cut short \[of the target\]', it acts up to the first character typed, but doesn't include it. This is in contrast to `s` itself, which does include the first character typed--to keep it consistent with the `f` behavior--but not the second character.

Lastly but quite useful, `j` jumps to the next word containing the characters typed, acting on the whole word. It's the equivalent of `iw`, but sniping the target from a distance. Typing `cjth` takes you to the next word contaiting "th", deleting it and leaving you in insert mode.

As expected, `c' and `j` are complemented by the reversed `C` and `J`.
