" Vim filetype plugin file
" Language:	PKG(5) package manifest
" Maintainer:	sa@omnios.org
" Last Change:	2021 November 10

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal comments=:#
setlocal commentstring=#\ %s
setlocal formatoptions-=t
setlocal formatoptions+=ql

let b:undo_ftplugin = "setlocal com< cms< fo<"

let &cpo = s:cpo_save
unlet s:cpo_save

