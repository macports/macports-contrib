" vim:fenc=utf-8:et:sw=4:ts=4:sts=4

" Vim compiler file
" Author: Maximilian Nickel <mnick@macports.org>

if exists("current_compiler")
    finish
endif
let current_compiler = "portfile"

setlocal makeef=/tmp/portfile##.err
setlocal makeprg=cd\ %:p:h\ &&\ port\ lint\ --nitpick\ 2>&1\ \\\|\ grep\ -v\ \"\\\-\\\->\" 
setlocal errorformat=Warning\:\ Line\ %l\ %m,Error\:%m,Warn\:%m,%m
