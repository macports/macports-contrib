" Vim filetype plugin for portfile
" Author: Maximilian Nickel <mnick@macports.org>

if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

if exists("g:did_macportsplugin") 
	function PortfileGetErrors()
		if !empty(getqflist())
			exe "copen"
		end
	endfunction
endif
let g:did_macportsplugin = 1

au QuickFixCmdPre make exe "cclose"
au QuickFixCmdPost make call PortfileGetErrors()
